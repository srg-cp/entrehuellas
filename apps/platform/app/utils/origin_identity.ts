// Copy only the triggering control, with its actual layout and appearance.
// This visual lives in memory for the transition, outside focus and semantics.
export function captureOriginIdentity(element: HTMLElement): HTMLElement {
  const copy = element.cloneNode(true) as HTMLElement;
  const originals = [element, ...element.querySelectorAll('*')];
  const copies = [copy, ...copy.querySelectorAll('*')];
  for (let i = 0; i < copies.length; i++) {
    const node = copies[i] as HTMLElement | SVGElement;
    const style = getComputedStyle(originals[i]!);
    for (const property of style) node.style.setProperty(property, style.getPropertyValue(property));
    for (const attribute of [...node.attributes]) {
      if (/^on/i.test(attribute.name) || /^(id|class|href|tabindex|autofocus)$/.test(attribute.name) || attribute.name.startsWith('data-')) node.removeAttribute(attribute.name);
    }
    Object.assign(node.style, {animation: 'none', transition: 'none', pointerEvents: 'none'});
  }
  const bounds = element.getBoundingClientRect();
  Object.assign(copy.style, {
    position: 'relative', left: 'auto', top: 'auto', right: 'auto', bottom: 'auto',
    width: `${bounds.width}px`, height: `${bounds.height}px`, minWidth: '0',
    minHeight: '0', maxWidth: 'none', maxHeight: 'none', margin: '0',
    transform: 'none', visibility: 'visible', flexShrink: '0',
    background: 'transparent', borderColor: 'transparent', boxShadow: 'none',
    backdropFilter: 'none',
  });
  copy.inert = true;
  copy.setAttribute('aria-hidden', 'true');
  return copy;
}
