import { t } from './i18n'

type Platform = 'PS5' | 'PS4'
const api = 'https://countapi.mileshilliard.com/api/v1'
// Public identifiers, not secrets. The suffixes prevent accidental key collisions.
const keys: Record<Platform, string> = {
  PS5: 'owendswang_esp32_project_flash_ps5_83df9183184060fcb17827af',
  PS4: 'owendswang_esp32_project_flash_ps4_6b1576e436b70ace8020525b',
}
const platforms: Platform[] = ['PS5', 'PS4']
const cooldown = 10000

export function initFlashCounts() {
  const outputs = Object.fromEntries(platforms.map(platform => [platform,
    document.querySelector<HTMLElement>(`[data-flash-count="${platform}"]`)!,
  ])) as Record<Platform, HTMLElement>
  const values: Record<Platform, number | null> = { PS5: null, PS4: null }
  const states = { PS5: 'loading', PS4: 'loading' }
  const revisions = { PS5: 0, PS4: 0 }
  const lastReports = { PS5: 0, PS4: 0 }
  const canReport = location.origin === 'https://owendswang.github.io'
    && location.pathname.startsWith('/ps5-webkit-autoloader-esp32/')

  function render() {
    const format = new Intl.NumberFormat('en', { notation: 'compact', compactDisplay: 'short', maximumFractionDigits: 1 })
    const fullFormat = new Intl.NumberFormat(document.documentElement.lang, { useGrouping: true })
    for (const platform of platforms) {
      const value = values[platform]
      outputs[platform].textContent = value === null ? '—' : format.format(value)
      outputs[platform].title = t(states[platform] === 'loading' ? 'Loading counts…'
        : states[platform] === 'error' ? 'Count temporarily unavailable' : 'Reported successful flashes: {count}', { count: fullFormat.format(value ?? 0) })
      outputs[platform].setAttribute('aria-label', `${platform}: ${outputs[platform].title}`)
    }
  }

  async function request(platform: Platform, action: 'get' | 'hit') {
    const response = await fetch(`${api}/${action}/${keys[platform]}`, {
      cache: 'no-store', credentials: 'omit', referrerPolicy: 'no-referrer',
      signal: AbortSignal.timeout(6000),
    })
    const body = await response.json()
    if (action === 'get' && response.status === 404 && body.error === 'Key not found') return 0
    const value = typeof body.value === 'string' && /^\d+$/.test(body.value) ? Number(body.value) : body.value
    if (!response.ok || body.key !== keys[platform] || !Number.isSafeInteger(value) || value < 0) {
      throw new Error('Invalid flash count response')
    }
    return value as number
  }

  async function load(platform: Platform) {
    const revision = revisions[platform]
    try {
      const value = await request(platform, 'get')
      if (revision !== revisions[platform]) return
      values[platform] = value
      states[platform] = 'ready'
    } catch {
      if (revision !== revisions[platform]) return
      states[platform] = 'error'
    }
    render()
  }

  async function report(platform: Platform) {
    const storageKey = `esp32-flasher-count-${keys[platform]}`
    const now = Date.now()
    let previous = lastReports[platform]
    try { previous = Math.max(previous, Number(localStorage.getItem(storageKey)) || 0) } catch { /* Use in-memory deduplication. */ }
    if (now >= previous && now - previous < cooldown) return
    // Mark before sending: a lost response must not cause another increment.
    lastReports[platform] = now
    try { localStorage.setItem(storageKey, String(now)) } catch { /* Storage may be unavailable. */ }
    revisions[platform]++
    try {
      values[platform] = await request(platform, 'hit')
      states[platform] = 'ready'
    } catch {
      states[platform] = 'error'
      values[platform] = null
    }
    render()
  }

  window.addEventListener('flasher:language', render)
  render()
  platforms.forEach(platform => { void load(platform) })

  // Capture the platform at the start of one validated project flash. Call the
  // returned function only after writeFlash resolves with verification complete.
  return (platform: string | undefined) => {
    let reported = false
    return async () => {
      if (reported || !canReport || (platform !== 'PS5' && platform !== 'PS4')) return
      reported = true
      try {
        if (navigator.locks) await navigator.locks.request(`esp32-flasher-count-${platform}`, () => report(platform))
        else await report(platform)
      } catch { /* Statistics must never change the flash result. No automatic retries. */ }
    }
  }
}
