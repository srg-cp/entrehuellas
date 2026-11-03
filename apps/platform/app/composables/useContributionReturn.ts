import { contributionDestination } from '#shared/routing/route_policy';

// Only a validated internal QR destination survives login/onboarding.
export function useContributionReturn() {
  const pending = useCookie<string | null>('eh_contribution_return', { sameSite:'lax', path:'/', maxAge:3600 });
  return () => { const destination = contributionDestination(pending.value); pending.value = null; return destination || '/inicio'; };
}
