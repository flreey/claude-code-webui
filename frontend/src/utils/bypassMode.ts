/**
 * Bypass mode configuration utilities
 * Controls whether the dangerous "bypassPermissions" mode is available in the UI
 */

/**
 * Check if bypass mode is enabled via environment variable
 * Only enabled when VITE_ENABLE_BYPASS_MODE=true is explicitly set
 */
export function isBypassModeEnabled(): boolean {
  return import.meta.env.VITE_ENABLE_BYPASS_MODE === "true";
}

/**
 * Get available permission modes based on environment configuration
 * Includes bypassPermissions only if explicitly enabled
 */
export function getAvailablePermissionModes(): string[] {
  const baseModes = ["default", "plan", "acceptEdits"];

  if (isBypassModeEnabled()) {
    return [...baseModes, "bypassPermissions"];
  }

  return baseModes;
}

/**
 * Check if a specific permission mode is available
 */
export function isPermissionModeAvailable(mode: string): boolean {
  return getAvailablePermissionModes().includes(mode);
}
