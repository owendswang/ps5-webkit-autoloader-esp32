import { createHash } from 'node:crypto'
import { mkdir, readFile, readdir, rename, rm, writeFile } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'
import { setTimeout } from 'node:timers/promises'
import { EnvHttpProxyAgent, setGlobalDispatcher } from 'undici'

setGlobalDispatcher(new EnvHttpProxyAgent({ connect: { timeout: 60000 } }))

const repository = process.env.GITHUB_REPOSITORY || 'owendswang/ps5-webkit-autoloader-esp32'
const root = new URL('../public/releases/', import.meta.url)
const api = `https://api.github.com/repos/${repository}/releases`
const headers = { Accept: 'application/vnd.github+json' }
if (process.env.GITHUB_TOKEN) headers.Authorization = `Bearer ${process.env.GITHUB_TOKEN}`

async function request(url, options = {}) {
  for (let attempt = 0; ; attempt++) {
    try {
      const response = await fetch(url, { ...options, signal: AbortSignal.timeout(120000) })
      if (response.ok) return response
      const message = `GitHub returned ${response.status} for ${url}`
      if (response.status < 500 && response.status !== 429) throw new Error(message, { cause: 'permanent' })
      throw new Error(message)
    } catch (error) {
      if (attempt === 3 || error.cause === 'permanent') throw error
      await setTimeout(1000 * 2 ** attempt)
    }
  }
}

await mkdir(root, { recursive: true })
const releases = []
for (let page = 1; ; page++) {
  const list = await (await request(`${api}?per_page=100&page=${page}`, { headers })).json()
  releases.push(...list.filter(release => !release.draft))
  if (list.length < 100) break
}
const latest = (await (await request(`${api}/latest`, { headers })).json()).tag_name
const catalog = []
const downloads = []
let completed = 0
const counts = { PS5: 0, PS4: 0 }
releases.sort((a, b) => Date.parse(b.published_at) - Date.parse(a.published_at))
for (const release of releases) {
  const assets = release.assets.filter(asset => /^esp32-arduino\.(pico|s2|s3|c3)\.merged(?:[-.].*)?\.bin$/i.test(asset.name))
  if (!assets.length) continue
  // Older PS5 prereleases and the first stable PS4 release have inverted flags.
  const ps4 = /ps4/i.test(`${release.tag_name} ${release.name}`) || assets.some(asset => /ps4/i.test(asset.name))
  const platform = ps4 ? 'PS4' : /^v\d/i.test(release.tag_name) ? 'PS5' : release.prerelease ? 'PS4' : 'PS5'
  if (counts[platform] >= 4) continue
  counts[platform]++
  const entry = {
    tag: release.tag_name, platform, latest: platform === 'PS5' && release.tag_name === latest,
    published: release.published_at, url: release.html_url, assets: [],
  }
  for (const asset of assets) {
    const model = asset.name.match(/^esp32-arduino\.(pico|s2|s3|c3)\./i)[1].toUpperCase()
    const path = `files/${asset.id}.bin`
    const item = { model: `ESP32-${model}`, name: asset.name, size: asset.size, path, sha256: '' }
    entry.assets.push(item)
    downloads.push(async () => {
      const target = new URL(path, root)
      const expected = asset.digest?.startsWith('sha256:') ? asset.digest.slice(7) : null
      const hash = data => createHash('sha256').update(data).digest('hex')
      let bytes
      try { bytes = await readFile(target) } catch { /* First download. */ }
      if (!bytes || bytes.length !== asset.size || !expected || hash(bytes) !== expected) {
        bytes = Buffer.from(await (await request(asset.browser_download_url)).arrayBuffer())
        if (bytes.length !== asset.size || (expected && hash(bytes) !== expected)) throw new Error(`Invalid firmware download: ${asset.name}`)
        await writeFile(new URL(`${path}.tmp`, root), bytes)
        await rename(new URL(`${path}.tmp`, root), target)
      }
      item.sha256 = hash(bytes)
      completed++
      if (completed % 16 === 0) console.log(`Verified ${completed} firmware images`)
    })
  }
  catalog.push(entry)
}
await mkdir(new URL('files/', root), { recursive: true })
await Promise.all(Array.from({ length: 12 }, async () => {
  while (downloads.length) await downloads.shift()()
}))
catalog.sort((a, b) => Date.parse(b.published) - Date.parse(a.published))
await writeFile(new URL('catalog.json.tmp', root), JSON.stringify({ repository, releases: catalog }, null, 2))
await rename(new URL('catalog.json.tmp', root), new URL('catalog.json', root))
const retainedFiles = new Set(catalog.flatMap(release => release.assets.map(asset => asset.path.slice('files/'.length))))
for (const filename of await readdir(new URL('files/', root))) {
  if (/^\d+\.bin(?:\.tmp)?$/.test(filename) && !retainedFiles.has(filename)) {
    await rm(new URL(`files/${filename}`, root))
  }
}
const totalBytes = catalog.flatMap(release => release.assets).reduce((sum, asset) => sum + asset.size, 0)
console.log(`Synced ${catalog.length} releases, ${completed} firmware images (${(totalBytes / 1024 ** 2).toFixed(1)} MiB) to ${fileURLToPath(root)}`)
