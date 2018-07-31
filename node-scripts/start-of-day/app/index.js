#!/usr/env/node

/* @flow */

import Future from "fluture";
import { pipeK } from "ramda";

import {
	executeCommandInheritStdout,
	singlePrompt,
} from "@eric.dahlseng/cli-tools";

// -----------------------------------------------------------------------------
// Actions
// -----------------------------------------------------------------------------

const runStartOfDay = pipeK(
	() => executeCommandInheritStdout("open -a Notes"),
	() =>
		singlePrompt({
			type: "confirm",
			message: "Would you like to continue?",
			default: true,
		}).chain(
			shouldContinue => (shouldContinue ? Future.of() : Future.reject())
		),
	() => executeCommandInheritStdout("open -a Calendar"),
	() =>
		singlePrompt({
			type: "confirm",
			message: "Would you like to continue?",
			default: true,
		}).chain(
			shouldContinue => (shouldContinue ? Future.of() : Future.reject())
		),
	() =>
		executeCommandInheritStdout(
			"open https://github.com/pulls/review-requested https://github.com/pulls?utf8=✓&q=is:open+is:pr+review:changes_requested+reviewed-by:edahlseng+archived:false"
		),
	() =>
		singlePrompt({
			type: "confirm",
			message: "Would you like to continue?",
			default: true,
		}).chain(
			shouldContinue => (shouldContinue ? Future.of() : Future.reject())
		),
	() => executeCommandInheritStdout("task +work"),
	() =>
		singlePrompt({
			type: "confirm",
			message: "Would you like to continue?",
			default: true,
		}).chain(
			shouldContinue => (shouldContinue ? Future.of() : Future.reject())
		),
	() =>
		executeCommandInheritStdout(
			"open https://shaper.atlassian.net/secure/RapidBoard.jspa?rapidView=12&projectKey=WEB&quickFilter=28"
		)
);

// -----------------------------------------------------------------------------
// Run
// -----------------------------------------------------------------------------

runStartOfDay(Future.of()).fork(
	error => error && console.error, // eslint-disable-line no-console, no-undef
	() => {}
);
