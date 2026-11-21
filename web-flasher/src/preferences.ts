import { setLanguage, t, translatePage } from './i18n'

type Theme = 'system' | 'light' | 'dark'
type Locale = 'system' | 'en' | 'zh'

function readPreference<T extends string>(key: string, allowed: readonly T[], fallback: T) {
  try {
    const value = localStorage.getItem(key) as T
    return allowed.includes(value) ? value : fallback
  } catch { return fallback }
}

function savePreference(key: string, value: string) {
  try { localStorage.setItem(key, value) } catch { /* Preferences still work for this visit. */ }
}

export function initPreferences() {
  const html = document.documentElement
  const themeButton = document.querySelector<HTMLButtonElement>('#theme')!
  const languageSelect = document.querySelector<HTMLSelectElement>('#language')!
  const dark = matchMedia('(prefers-color-scheme: dark)')
  const reduced = matchMedia('(prefers-reduced-motion: reduce)')
  let theme = readPreference<Theme>('esp32-flasher-theme', ['system', 'light', 'dark'], 'system')
  let locale = readPreference<Locale>('esp32-flasher-language', ['system', 'en', 'zh'], 'system')
  let transition: ViewTransition | undefined
  let revision = 0
  let transitionTimer: ReturnType<typeof setTimeout>

  // From automatic, switch to the opposite appearance first, then back to the
  // system's appearance, then automatic, keeping system following available.
  const nextTheme = (): Theme => {
    const system = dark.matches ? 'dark' : 'light'
    if (theme === 'system') return system === 'dark' ? 'light' : 'dark'
    return theme === system ? 'system' : system
  }
  const renderThemeButton = () => {
    const name = (value: Theme) => t(value === 'system' ? 'Follow system' : value === 'dark' ? 'Dark' : 'Light')
    const label = t('Appearance: {current}. Switch to {next}.', { current: name(theme), next: name(nextTheme()) })
    themeButton.dataset.mode = theme
    themeButton.setAttribute('aria-label', label)
    themeButton.title = label
  }

  const applyTheme = (animate = true) => {
    const next = theme === 'system' ? (dark.matches ? 'dark' : 'light') : theme
    const current = ++revision
    transition?.skipTransition()
    renderThemeButton()
    if (html.dataset.theme === next) {
      document.querySelector('meta[name="theme-color"]')!.setAttribute('content', next === 'dark' ? '#10141d' : '#eef0f3')
      return
    }
    const commit = () => {
      if (current !== revision) return
      html.dataset.theme = next
      document.querySelector('meta[name="theme-color"]')!.setAttribute('content', next === 'dark' ? '#10141d' : '#eef0f3')
    }
    if (animate && !reduced.matches && html.dataset.motion !== 'off' && document.startViewTransition) {
      transition = document.startViewTransition(commit)
      transition.ready.catch(() => {})
      transition.finished.catch(() => {})
    } else {
      if (animate && !reduced.matches && html.dataset.motion !== 'off') {
        html.classList.add('theme-switching')
        clearTimeout(transitionTimer)
        transitionTimer = setTimeout(() => html.classList.remove('theme-switching'), 350)
      }
      commit()
    }
  }

  const applyLanguage = () => {
    window.dispatchEvent(new Event('flasher:before-language'))
    const preferred = navigator.languages?.[0] || navigator.language
    setLanguage(locale === 'system' ? (/^zh(?:-|$)/i.test(preferred) ? 'zh' : 'en') : locale)
    translatePage()
    renderThemeButton()
    window.dispatchEvent(new Event('flasher:language'))
  }

  languageSelect.value = locale
  applyTheme(false)
  applyLanguage()
  themeButton.addEventListener('click', () => {
    theme = nextTheme()
    savePreference('esp32-flasher-theme', theme)
    applyTheme()
  })
  languageSelect.addEventListener('change', () => {
    locale = languageSelect.value as Locale
    savePreference('esp32-flasher-language', locale)
    applyLanguage()
  })
  dark.addEventListener('change', () => {
    if (theme === 'system') applyTheme()
    else renderThemeButton()
  })
  window.addEventListener('languagechange', () => { if (locale === 'system') applyLanguage() })
  reduced.addEventListener('change', () => { if (reduced.matches) transition?.skipTransition() })
}
