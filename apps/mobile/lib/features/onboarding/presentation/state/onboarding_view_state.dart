final class OnboardingViewState {
  const OnboardingViewState({
    this.page = 0,
    this.isBusy = false,
    this.hasError = false,
    this.completed = false,
  });
  final int page;
  final bool isBusy;
  final bool hasError;
  final bool completed;
}
