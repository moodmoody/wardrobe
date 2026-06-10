List<String> moveItemToTop(List<String> stack, String itemId) {
  return moveItemToPosition(stack, itemId, 1);
}

List<String> moveItemToPosition(List<String> stack, String itemId, int oneBasedPosition) {
  final currentIndex = stack.indexOf(itemId);
  if (currentIndex == -1) {
    return [...stack];
  }

  final nextStack = stack.where((id) => id != itemId).toList();
  final targetIndex = (oneBasedPosition - 1).clamp(0, nextStack.length);
  nextStack.insert(targetIndex, itemId);
  return nextStack;
}