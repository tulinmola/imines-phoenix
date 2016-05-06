module.exports = typeof window === "undefined"? require("events"): EventEmitter
