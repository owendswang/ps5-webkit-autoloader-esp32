const html = document.documentElement
const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)')
const enabled = () => !reducedMotion.matches && html.dataset.motion !== 'off'
const easing = 'cubic-bezier(.22, 1, .36, 1)'
const shakes = new Map<HTMLElement, Animation>()

export function shakeInvalid(elements: HTMLElement[]) {
  if (!enabled()) return
  for (const element of elements) {
    shakes.get(element)?.cancel()
    const animation = element.animate(
      [0, -5, 4, -3, 2, 0].map(value => ({ translate: `${value}px 0` })),
      { duration: 320, easing: 'ease-out' },
    )
    shakes.set(element, animation)
    const remove = () => { if (shakes.get(element) === animation) shakes.delete(element) }
    animation.finished.then(remove, remove)
  }
}

export function initMotion() {
  const animations = new Set<Animation>()
  const settleDisclosures = new Set<() => void>()
  const animate = (element: HTMLElement, frames: Keyframe[], options: KeyframeAnimationOptions) => {
    const animation = element.animate(frames, options)
    animations.add(animation)
    const remove = () => { animations.delete(animation) }
    animation.finished.then(remove, remove)
    return animation
  }

  const reveal = (item: HTMLElement) => {
    if (item.hasAttribute('data-revealed')) return
    item.dataset.revealed = 'true'
    const group = item.closest<HTMLElement>('[data-reveal]')!
    group.dataset.revealed = 'true'
    if (!enabled()) return
    const index = Array.from(group.querySelectorAll('[data-reveal-item]')).indexOf(item)
    const animation = animate(item, [
      { opacity: 0, translate: '0 12px' },
      { opacity: 1, translate: '0 0' },
    ], { duration: 500, delay: Math.min(index * 45, 270), easing, fill: 'both' })
    // Release the animation's styles so hover and later interactions remain independent.
    animation.finished.then(() => animation.cancel(), () => {})
  }
  const observer = new IntersectionObserver(entries => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue
      reveal(entry.target as HTMLElement)
      observer.unobserve(entry.target)
    }
  }, { rootMargin: '0px 0px -24px 0px', threshold: 0.01 })

  const items = Array.from(document.querySelectorAll<HTMLElement>('[data-reveal-item]'))
  for (const item of items) {
    // Run this check now as well as observing: the first screen never waits for a scroll event.
    const bounds = item.getBoundingClientRect()
    if (!enabled() || (bounds.top < innerHeight && bounds.bottom > 0)) reveal(item)
    else observer.observe(item)
    item.addEventListener('focusin', () => reveal(item), { once: true })
  }

  for (const details of Array.from(document.querySelectorAll<HTMLDetailsElement>('details'))) {
    const summary = details.querySelector<HTMLElement>(':scope > summary')
    if (!summary) continue
    const contents = Array.from(details.children).filter((child): child is HTMLElement => child instanceof HTMLElement && child !== summary)
    let expanded = details.open
    let heightAnimation: Animation | undefined
    let fades: Animation[] = []
    let stopFollowing = () => {}
    const followExpansion = () => {
      if (!details.closest('.site-footer')) return
      const controller = new AbortController()
      let frame = 0
      details.dataset.followExpansion = 'true'
      stopFollowing = () => {
        cancelAnimationFrame(frame)
        controller.abort()
        delete details.dataset.followExpansion
      }
      const follow = () => {
        const headerBottom = document.querySelector('.site-header')?.getBoundingClientRect().bottom ?? 0
        const overflow = Math.max(0, details.getBoundingClientRect().bottom - innerHeight + 24)
        // Keep the summary below the sticky header, even when its content exceeds one screen.
        const room = Math.max(0, summary.getBoundingClientRect().top - headerBottom - 16)
        if (overflow > 0 && room > 0) scrollBy({ top: Math.min(overflow, room), behavior: 'instant' })
        frame = requestAnimationFrame(follow)
      }
      const stop = () => stopFollowing()
      for (const type of ['wheel', 'touchstart', 'pointerdown']) {
        window.addEventListener(type, stop, { passive: true, signal: controller.signal })
      }
      window.addEventListener('keydown', event => {
        if (['ArrowUp', 'ArrowDown', 'PageUp', 'PageDown', 'Home', 'End', ' '].includes(event.key)) stop()
      }, { signal: controller.signal })
      frame = requestAnimationFrame(follow)
    }
    const settle = () => {
      stopFollowing()
      details.open = expanded
      heightAnimation?.cancel()
      heightAnimation = undefined
      fades.forEach(animation => animation.cancel())
      fades = []
      delete details.dataset.disclosureMoving
      settleDisclosures.delete(settle)
    }

    summary.addEventListener('click', event => {
      event.preventDefault()
      const startHeight = details.getBoundingClientRect().height
      const opacities = contents.map(item => details.open ? getComputedStyle(item).opacity : '0')
      expanded = !expanded
      stopFollowing()
      heightAnimation?.cancel()
      fades.forEach(animation => animation.cancel())
      contents.forEach(item => { item.inert = !expanded })
      if (!enabled()) return settle()

      // Keep native details open during collapse so its contents can animate in both directions.
      details.open = true
      const style = getComputedStyle(details)
      const collapsedHeight = summary.getBoundingClientRect().height
        + parseFloat(style.paddingTop) + parseFloat(style.paddingBottom)
        + parseFloat(style.borderTopWidth) + parseFloat(style.borderBottomWidth)
      const endHeight = expanded ? details.getBoundingClientRect().height : collapsedHeight
      details.dataset.disclosureMoving = 'true'
      settleDisclosures.add(settle)
      const animation = animate(details, [{ height: `${startHeight}px` }, { height: `${endHeight}px` }], {
        duration: expanded ? 300 : 240, easing, fill: 'both',
      })
      heightAnimation = animation
      fades = contents.map((item, index) => animate(item, [
        { opacity: opacities[index] }, { opacity: expanded ? 1 : 0 },
      ], { duration: 180, easing, fill: 'both' }))
      animation.onfinish = () => { if (heightAnimation === animation) settle() }
      if (expanded) followExpansion()
    })
    details.addEventListener('toggle', () => {
      if (!heightAnimation) expanded = details.open
    })
  }

  reducedMotion.addEventListener('change', () => {
    if (!reducedMotion.matches) return
    shakes.forEach(animation => animation.cancel())
    settleDisclosures.forEach(settle => settle())
    animations.forEach(animation => animation.cancel())
    items.forEach(reveal)
    observer.disconnect()
  })
  window.addEventListener('flasher:before-language', () => settleDisclosures.forEach(settle => settle()))
  html.setAttribute('data-ui-motion-ready', '')
}
