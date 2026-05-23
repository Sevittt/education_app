"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onQuizCreated = exports.onNewsCreated = exports.onSystemUpdated = exports.onSystemCreated = exports.dailyStreakReminder = void 0;
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
var streakReminder_1 = require("./triggers/streakReminder");
Object.defineProperty(exports, "dailyStreakReminder", { enumerable: true, get: function () { return streakReminder_1.dailyStreakReminder; } });
var onSystemCreatedOrUpdated_1 = require("./triggers/onSystemCreatedOrUpdated");
Object.defineProperty(exports, "onSystemCreated", { enumerable: true, get: function () { return onSystemCreatedOrUpdated_1.onSystemCreated; } });
Object.defineProperty(exports, "onSystemUpdated", { enumerable: true, get: function () { return onSystemCreatedOrUpdated_1.onSystemUpdated; } });
var onNewsCreated_1 = require("./triggers/onNewsCreated");
Object.defineProperty(exports, "onNewsCreated", { enumerable: true, get: function () { return onNewsCreated_1.onNewsCreated; } });
var onQuizCreated_1 = require("./triggers/onQuizCreated");
Object.defineProperty(exports, "onQuizCreated", { enumerable: true, get: function () { return onQuizCreated_1.onQuizCreated; } });
//# sourceMappingURL=index.js.map