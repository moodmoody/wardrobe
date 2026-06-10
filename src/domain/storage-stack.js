export function moveItemToTop(stack, itemId) {
  return moveItemToPosition(stack, itemId, 1);
}

export function moveItemToPosition(stack, itemId, oneBasedPosition) {
  const currentIndex = stack.indexOf(itemId);
  if (currentIndex === -1) {
    return [...stack];
  }

  const nextStack = stack.filter((id) => id !== itemId);
  const targetIndex = Math.max(0, Math.min(nextStack.length, oneBasedPosition - 1));
  nextStack.splice(targetIndex, 0, itemId);
  return nextStack;
}