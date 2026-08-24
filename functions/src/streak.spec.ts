import assert from "node:assert/strict";

import { computeStreakUpdate } from "./streak";

describe("computeStreakUpdate", () => {
  it("starts the streak at 1 when there is no prior activity", () => {
    const result = computeStreakUpdate({
      now: new Date("2026-07-07T10:00:00Z"),
      lastActivityDate: null,
      currentStreakDays: 0,
      longestStreakDays: 0,
    });

    assert.equal(result.currentStreakDays, 1);
    assert.equal(result.longestStreakDays, 1);
  });

  it("keeps the streak unchanged for a second activity the same UTC day", () => {
    const result = computeStreakUpdate({
      now: new Date("2026-07-07T22:00:00Z"),
      lastActivityDate: new Date("2026-07-07T08:00:00Z"),
      currentStreakDays: 4,
      longestStreakDays: 10,
    });

    assert.equal(result.currentStreakDays, 4);
    assert.equal(result.longestStreakDays, 10);
  });

  it("increments the streak for activity exactly one day later", () => {
    const result = computeStreakUpdate({
      now: new Date("2026-07-08T09:00:00Z"),
      lastActivityDate: new Date("2026-07-07T22:00:00Z"),
      currentStreakDays: 4,
      longestStreakDays: 4,
    });

    assert.equal(result.currentStreakDays, 5);
    assert.equal(result.longestStreakDays, 5);
  });

  it("resets the streak to 1 after a gap of more than one day", () => {
    const result = computeStreakUpdate({
      now: new Date("2026-07-10T09:00:00Z"),
      lastActivityDate: new Date("2026-07-07T09:00:00Z"),
      currentStreakDays: 6,
      longestStreakDays: 6,
    });

    assert.equal(result.currentStreakDays, 1);
    assert.equal(result.longestStreakDays, 6);
  });

  it("never lowers longestStreakDays below its previous value", () => {
    const result = computeStreakUpdate({
      now: new Date("2026-07-10T09:00:00Z"),
      lastActivityDate: new Date("2026-07-07T09:00:00Z"),
      currentStreakDays: 6,
      longestStreakDays: 30,
    });

    assert.equal(result.longestStreakDays, 30);
  });
});
