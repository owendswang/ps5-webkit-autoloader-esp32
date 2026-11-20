// Run Wobkot's vendored Relapse chain through the active Wobkot userland.
// The kernel exploit, cleanup, jailbreak patches and kexp/elfldr handoff live
// in vendor/wobkot; this payload is deliberately only an invocation boundary.
return async function (api) {
  if (!window.wobkot || typeof window.wobkot.runRelapse !== "function")
    throw new Error("Wobkot runtime is not active");

  await api.log(`Wobkot Relapse on PS5 ${api.fw}`, "info");
  await window.wobkot.runRelapse();
  await api.log("Wobkot Relapse completed", "success");
};
