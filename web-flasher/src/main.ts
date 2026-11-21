import '@fontsource-variable/chivo/wght.css'
import { md5 } from '@noble/hashes/legacy.js'
import { bytesToHex } from '@noble/hashes/utils.js'
import { ESPLoader, Transport } from 'esptool-js'
import installerLicense from '../LICENSE?raw'
import { initMotion, shakeInvalid } from './motion'
import './style.css'

document.querySelector<HTMLElement>('#installer-license')!.textContent = installerLicense
document.querySelector<HTMLAnchorElement>('#bundled-licenses')!.hidden = !import.meta.env.PROD
initMotion()

const form = document.querySelector<HTMLFormElement>('#flash-form')!
const boardPicker = document.querySelector<HTMLFieldSetElement>('#board-picker')!
const boardInstructions = document.querySelector<HTMLElement>('#board-instructions')!
const boardPhoto = document.querySelector<HTMLImageElement>('#board-photo')!
const boardUnknown = document.querySelector<HTMLElement>('#board-unknown')!
const platform = document.querySelector<HTMLSelectElement>('#platform')!
const version = document.querySelector<HTMLSelectElement>('#version')!
const firmwareNote = document.querySelector<HTMLElement>('#firmware-note')!
const releaseLink = document.querySelector<HTMLAnchorElement>('#release-link')!
const releaseTab = document.querySelector<HTMLButtonElement>('#release-tab')!
const localTab = document.querySelector<HTMLButtonElement>('#local-tab')!
const releasePanel = document.querySelector<HTMLFieldSetElement>('#release-panel')!
const localPanel = document.querySelector<HTMLFieldSetElement>('#local-panel')!
const firmware = document.querySelector<HTMLInputElement>('#firmware')!
const offset = document.querySelector<HTMLInputElement>('#offset')!
const button = document.querySelector<HTMLButtonElement>('#flash-button')!
const issue = document.querySelector<HTMLElement>('#issue')!
const status = document.querySelector<HTMLElement>('#flash-status')!
const statusText = document.querySelector<HTMLElement>('#status-text')!
const percent = document.querySelector<HTMLElement>('#percent')!
const progress = document.querySelector<HTMLProgressElement>('#progress')!
const log = document.querySelector<HTMLElement>('#serial-log')!

const serial = navigator.serial
const canFlash = window.isSecureContext && Boolean(serial)
let busy = false
let source: 'release' | 'local' = 'release'
type Asset = { model: string; name: string; path: string; size: number; sha256: string }
type Release = { tag: string; platform: string; latest: boolean; url: string; assets: Asset[] }
let releases: Release[] = []
let releaseState: 'loading' | 'ready' | 'error' = 'loading'
let validationAttempted = false
const fields = { board: boardPicker, platform, version, firmware, offset }
type Field = keyof typeof fields
type ValidationIssue = { field: Field; message: string }
const fieldLabels: Record<Field, HTMLElement> = {
  board: boardPicker.querySelector('legend')!,
  platform: document.querySelector('label[for="platform"]')!,
  version: document.querySelector('label[for="version"]')!,
  firmware: document.querySelector('label[for="firmware"]')!,
  offset: document.querySelector('label[for="offset"]')!,
}

function validateSelection() {
  const errors: ValidationIssue[] = []
  const board = selectedBoard()
  if (!board) errors.push({ field: 'board', message: 'Select a board model.' })
  if (source === 'release') {
    if (!['PS5', 'PS4'].includes(platform.value)) {
      errors.push({ field: 'platform', message: 'Choose PS5 or PS4.' })
    } else if (releaseState === 'loading') {
      errors.push({ field: 'version', message: 'Project releases are still loading. Please wait.' })
    } else if (releaseState === 'error') {
      errors.push({ field: 'version', message: 'Project releases are unavailable. Reload the page or use Local firmware.' })
    } else if (!selectedRelease()) {
      errors.push({ field: 'version', message: 'No firmware version is selected. Choose another platform or use Local firmware.' })
    } else if (board && !selectedAsset()) {
      errors.push({ field: 'board', message: 'This release has no firmware for that board. Choose another board or release.' })
    }
  } else {
    const file = firmware.files?.[0]
    if (!file) errors.push({ field: 'firmware', message: 'Choose a .bin firmware file.' })
    else if (!file.size) errors.push({ field: 'firmware', message: 'The firmware file is empty. Choose a non-empty .bin.' })
    else if (!/\.bin$/i.test(file.name)) errors.push({ field: 'firmware', message: 'Choose a firmware file with the .bin extension.' })
    if (!offset.value.trim()) errors.push({ field: 'offset', message: 'Enter a write address.' })
    else if (!/^0x[\da-f]{1,8}$/i.test(offset.value.trim())) errors.push({ field: 'offset', message: 'Use a hexadecimal write address, such as 0x0.' })
    else if (localAddress() === null) errors.push({ field: 'offset', message: 'Align the write address to 4 KiB, such as 0x10000.' })
  }
  return errors
}

function renderValidation(errors: ValidationIssue[]) {
  for (const key of Object.keys(fields) as Field[]) {
    const invalid = errors.some(error => error.field === key)
    if (invalid) fields[key].setAttribute('aria-invalid', 'true')
    else fields[key].removeAttribute('aria-invalid')
    fieldLabels[key].classList.toggle('field-invalid-label', invalid)
  }
  showIssue(errors.map(error => error.message).join(' '))
}

function focusValidation(errors: ValidationIssue[]) {
  shakeInvalid(errors.map(error => error.field === 'board'
    ? boardPicker.querySelector<HTMLElement>('.board-options')!
    : fields[error.field]))
  const first = errors[0].field
  const target = first === 'board'
    ? boardPicker.querySelector<HTMLInputElement>('input:enabled') ?? boardPicker
    : first === 'version' && version.disabled ? platform : fields[first]
  target.focus({ preventScroll: true })
  const area = first === 'board' ? boardPicker : target
  const bounds = area.getBoundingClientRect()
  const headerBottom = document.querySelector('.site-header')!.getBoundingClientRect().bottom
  if (bounds.top < headerBottom + 16 || bounds.bottom > innerHeight - 16) {
    area.scrollIntoView({ block: 'center', behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth' })
  }
}

function selectedRelease() {
  return releases.find(release => release.tag === version.value && release.platform === platform.value)
}

function selectedAsset() {
  return selectedRelease()?.assets.find(asset => asset.model === selectedBoard()?.value)
}

function localAddress() {
  const text = offset.value.trim()
  const address = /^0x[\da-f]{1,8}$/i.test(text) ? Number(text) : NaN
  return Number.isSafeInteger(address) && address % 4096 === 0 ? address : null
}

function updateSelection() {
  if (busy) return
  const release = selectedRelease()
  const asset = selectedAsset()
  const file = firmware.files?.[0]
  const address = localAddress()
  const localReady = Boolean(file?.size && /\.bin$/i.test(file.name) && address !== null)
  const ready = source === 'release' ? Boolean(asset) : localReady
  button.disabled = false
  releasePanel.disabled = source !== 'release'
  localPanel.disabled = source !== 'local'
  offset.setCustomValidity(address === null ? 'Enter a hexadecimal address on a 4 KiB boundary.' : '')
  releaseLink.hidden = !release
  if (release) releaseLink.href = release.url
  firmwareNote.textContent = asset
    ? `${asset.name} · ${(asset.size / 1024 ** 2).toFixed(0)} MiB`
    : release ? 'Choose a board model available in this release.' : releaseState === 'loading' ? 'Loading releases…' : 'No firmware available for this platform.'
  for (const input of Array.from(boardPicker.querySelectorAll<HTMLInputElement>('input'))) {
    input.disabled = source === 'release' && !release?.assets.some(asset => asset.model === input.value)
  }
  if (canFlash) {
    const errors = validationAttempted ? validateSelection() : []
    if (validationAttempted) renderValidation(errors)
    showProgress(0)
    showStatus('idle', errors.length ? 'Check the highlighted fields' : ready && selectedBoard() ? 'Ready to flash' : source === 'local' ? 'Choose a board, file and write address' : 'Choose a release and board')
  }
}

function updateVersions() {
  const available = releases.filter(release => release.platform === platform.value)
  const preferred = available.find(release => release.latest) || available[0]
  version.replaceChildren(...available.map(release => new Option(
    `${release.platform === 'PS4' ? release.tag.replace(/^PS4-/i, '') : release.tag}${release === preferred ? ' · Latest' : ''}`, release.tag,
  )))
  version.disabled = busy || available.length === 0
  if (preferred) version.value = preferred.tag
  updateSelection()
}

async function loadReleases() {
  firmwareNote.textContent = 'Loading releases…'
  try {
    const response = await fetch(`${import.meta.env.BASE_URL}releases/catalog.json`, { cache: 'no-cache', signal: AbortSignal.timeout(30000) })
    if (!response.ok) throw new Error('Release catalog unavailable. Please try again later.')
    const catalog = await response.json()
    if (!Array.isArray(catalog.releases)) throw new Error('Release catalog unavailable. Please try again later.')
    releases = catalog.releases
    releaseState = 'ready'
    updateVersions()
  } catch (error) {
    releaseState = 'error'
    version.replaceChildren(new Option('Releases unavailable', ''))
    updateSelection()
    firmwareNote.textContent = errorMessage(error)
  }
}

function selectSource(next: 'release' | 'local') {
  if (busy || next === source) return
  source = next
  validationAttempted = false
  releaseTab.setAttribute('aria-selected', String(next === 'release'))
  localTab.setAttribute('aria-selected', String(next === 'local'))
  releaseTab.tabIndex = next === 'release' ? 0 : -1
  localTab.tabIndex = next === 'local' ? 0 : -1
  releasePanel.inert = next !== 'release'
  localPanel.inert = next !== 'local'
  releasePanel.dataset.active = String(next === 'release')
  localPanel.dataset.active = String(next === 'local')
  if (canFlash) renderValidation([])
  updateSelection()
}

for (const tab of [releaseTab, localTab]) {
  tab.addEventListener('click', () => selectSource(tab === releaseTab ? 'release' : 'local'))
  tab.addEventListener('keydown', event => {
    if (!['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) return
    event.preventDefault()
    const next = event.key === 'Home' ? releaseTab : event.key === 'End' ? localTab : tab === releaseTab ? localTab : releaseTab
    next.click()
    next.focus()
  })
}

function selectedBoard() {
  return boardPicker.querySelector<HTMLInputElement>('input:checked')
}

function showIssue(message: string) {
  if (issue.textContent !== message) issue.textContent = message
  issue.hidden = !message
}

function showStatus(state: 'idle' | 'active' | 'done' | 'error', message: string) {
  status.dataset.state = state
  const result = state === 'done' ? 'Success' : state === 'error' ? 'Failure' : ''
  statusText.textContent = result || message
  statusText.setAttribute('aria-label', result ? `${result}. ${message}` : message)
  statusText.title = message
  if (result) writeLog(`${message}\n`)
}

function showProgress(value: number) {
  progress.value = value
  status.style.setProperty('--progress', `${progress.position * 100}%`)
  percent.textContent = `${value}%`
}

function writeLog(text: string) {
  log.textContent = `${log.textContent}${text}`.slice(-20000)
  log.scrollTop = log.scrollHeight
}

function errorMessage(error: unknown) {
  return error instanceof Error ? error.message : String(error)
}

function protectWrite(event: BeforeUnloadEvent) {
  event.preventDefault()
  event.returnValue = ''
}

button.disabled = false
if (!canFlash) {
  showIssue(window.isSecureContext
    ? 'Web Serial is unavailable. Open this page in desktop Chrome or Edge.'
    : 'Open this page over HTTPS or from localhost to use Web Serial.')
  showStatus('error', 'Serial unavailable')
}

boardPicker.addEventListener('change', () => {
  if (busy) return
  const board = selectedBoard()
  if (board?.dataset.connection) boardInstructions.textContent = board.dataset.connection
  const thumbnail = board?.closest('label')?.querySelector('img')
  boardPhoto.hidden = !thumbnail
  boardUnknown.hidden = Boolean(thumbnail)
  if (thumbnail) {
    boardPhoto.src = thumbnail.src
    boardPhoto.alt = `${board!.value} USB dongle`
  }
  updateSelection()
})

platform.addEventListener('change', updateVersions)
version.addEventListener('change', updateSelection)
form.addEventListener('input', event => {
  // A platform change must populate its versions before validating the selection.
  if (event.target !== platform) updateSelection()
})
form.addEventListener('change', () => {
  if (busy || !canFlash || validationAttempted) return
  showIssue('')
})
void loadReleases()

form.addEventListener('submit', async event => {
  event.preventDefault()
  if (busy) return
  if (!canFlash) {
    showIssue(window.isSecureContext
      ? 'Web Serial is unavailable in this browser. Open this page in a browser with Web Serial support.'
      : 'Open this page over HTTPS or from localhost to use Web Serial.')
    return
  }
  validationAttempted = true
  const errors = validateSelection()
  renderValidation(errors)
  if (errors.length) {
    showProgress(0)
    showStatus('idle', 'Check the highlighted fields')
    focusValidation(errors)
    return
  }
  validationAttempted = false

  const board = selectedBoard()?.value
  if (!board) return

  const asset = source === 'release' ? selectedAsset() : undefined
  const file = source === 'local' ? firmware.files?.[0] : undefined
  const address = source === 'release' ? 0 : localAddress()
  if (address === null || (!asset && (!file?.size || !/\.bin$/i.test(file.name)))) return

  busy = true
  button.disabled = releasePanel.disabled = localPanel.disabled = boardPicker.disabled = releaseTab.disabled = localTab.disabled = true
  platform.disabled = version.disabled = firmware.disabled = offset.disabled = true
  boardPicker.inert = releasePanel.inert = localPanel.inert = true
  form.setAttribute('aria-busy', 'true')
  showIssue('')
  showProgress(0)
  showStatus('active', 'Choose a serial port')
  log.textContent = ''

  let port: SerialPort | undefined
  let transport: Transport | undefined
  try {
    port = await serial.requestPort()
    window.addEventListener('beforeunload', protectWrite)
    let downloaded: Uint8Array | undefined
    if (asset) downloaded = await downloadFirmware(asset)
    transport = new Transport(port)
    const loader = new ESPLoader({
      transport,
      baudrate: 460800,
      terminal: {
        // Preserve download entries when the loader resets its terminal.
        clean: () => { writeLog('\n') },
        writeLine: text => writeLog(`${text}\n`),
        write: writeLog,
      },
    })

    showStatus('active', 'Connecting to your board')
    const description = await loader.main()
    const detectedBoard = description.startsWith('ESP32-PICO') ? 'ESP32-PICO' : loader.chip.CHIP_NAME
    if (board !== detectedBoard) {
      throw new Error(`Selected ${board}, but the serial port reported ${description}. Check the board you selected.`)
    }

    const flashSize = await loader.detectFlashSize()
    const size = /^(\d+)(KB|MB)$/.exec(flashSize ?? '')
    if (!size) throw new Error('Could not detect the flash capacity of this board.')
    const capacity = Number(size[1]) * (size[2] === 'MB' ? 1024 ** 2 : 1024)
    const imageSize = asset?.size ?? file!.size
    if (address + Math.ceil(imageSize / 4) * 4 > capacity) throw new Error(`The image exceeds the board’s ${flashSize} flash capacity at this address.`)
    if (file) {
      showStatus('active', 'Reading local firmware')
      writeLog(`Local firmware: ${file.name} (${file.size} bytes)\n`)
    }
    const data = downloaded ?? new Uint8Array(await file!.arrayBuffer())

    showStatus('active', `Writing to ${detectedBoard}`)
    writeLog(`Writing ${data.length} bytes to ${detectedBoard} at 0x${address.toString(16)}\n`)
    progress.setAttribute('aria-label', 'Flash progress')
    showProgress(0)
    await loader.writeFlash({
      fileArray: [{ address, data }],
      flashSize: 'keep',
      flashMode: 'keep',
      flashFreq: 'keep',
      eraseAll: false,
      compress: true,
      calculateMD5Hash: data => bytesToHex(md5(data)),
      reportProgress: (_file, written, total) => {
        if (total <= 0) return
        showProgress(Math.min(99, Math.floor(written / total * 100)))
        if (written >= total) showStatus('active', 'Verifying data in flash')
      },
    })

    showProgress(100)
    showStatus('active', 'Restarting your board')
    try {
      await loader.after()
      showStatus('done', 'Firmware written and verified')
    } catch (error) {
      writeLog(`\nReset: ${errorMessage(error)}\n`)
      showStatus('done', 'Verified. Reconnect your board to restart it.')
    }
  } catch (error) {
    if (!port && error instanceof DOMException && error.name === 'NotFoundError') {
      const message = 'Port selection canceled. Click Flash firmware and select a serial port to try again.'
      showIssue(message)
      showStatus('error', message)
    } else {
      const message = errorMessage(error)
      writeLog(`\n${message}\n`)
      showIssue(message)
      showStatus('error', 'Flash failed')
    }
  } finally {
    if (transport && (port?.readable || port?.writable)) {
      try {
        await transport.disconnect()
      } catch (error) {
        const message = `Could not close the serial port. Reconnect the board before retrying. (${errorMessage(error)})`
        writeLog(`\n${message}\n`)
        showIssue(issue.hidden ? message : `${issue.textContent} ${message}`)
      }
    }
    window.removeEventListener('beforeunload', protectWrite)
    boardPicker.disabled = releaseTab.disabled = localTab.disabled = false
    platform.disabled = firmware.disabled = offset.disabled = false
    version.disabled = !releases.some(release => release.platform === platform.value)
    releasePanel.disabled = source !== 'release'
    localPanel.disabled = source !== 'local'
    boardPicker.inert = false
    releasePanel.inert = source !== 'release'
    localPanel.inert = source !== 'local'
    form.setAttribute('aria-busy', 'false')
    busy = false
    button.disabled = false
    if (document.activeElement === document.body) button.focus()
  }
})

async function downloadFirmware(asset: Asset) {
  showStatus('active', 'Downloading release firmware')
  progress.setAttribute('aria-label', 'Firmware download progress')
  showProgress(0)
  writeLog(`Downloading ${asset.name} (${asset.size} bytes)\nDownload 0%\n`)
  const response = await fetch(`${import.meta.env.BASE_URL}releases/${asset.path}`, { signal: AbortSignal.timeout(120000) })
  if (!response.ok) throw new Error('Firmware download failed. Reload the page and try again.')
  if (!response.body) throw new Error('Firmware download is unavailable. Please try again.')
  const reader = response.body.getReader()
  const data = new Uint8Array(asset.size)
  let downloaded = 0
  let reportedBucket = 0
  try {
    while (true) {
      const { done, value } = await reader.read()
      if (done) break
      if (downloaded + value.length > asset.size) {
        await reader.cancel()
        throw new Error('Firmware download has an unexpected size. Please try again.')
      }
      data.set(value, downloaded)
      downloaded += value.length
      const percentage = Math.floor(downloaded / asset.size * 100)
      showProgress(percentage)
      const bucket = Math.floor(percentage / 10)
      if (bucket > reportedBucket) {
        reportedBucket = bucket
        writeLog(`Download ${percentage}% · ${downloaded} / ${asset.size} bytes\n`)
      }
      showStatus('active', `Downloading firmware · ${(downloaded / 1024 ** 2).toFixed(1)} / ${(asset.size / 1024 ** 2).toFixed(1)} MiB`)
    }
  } finally {
    reader.releaseLock()
  }
  if (downloaded !== asset.size) throw new Error('Firmware download is incomplete. Please try again.')
  writeLog(`Download complete: ${downloaded} bytes. Checking SHA-256…\n`)
  showStatus('active', 'Checking firmware download')
  const digest = bytesToHex(new Uint8Array(await crypto.subtle.digest('SHA-256', data)))
  if (digest !== asset.sha256) throw new Error('Firmware checksum mismatch. Reload the page and try again.')
  writeLog(`Firmware: ${asset.name}\nSHA-256 verified.\n`)
  return data
}
