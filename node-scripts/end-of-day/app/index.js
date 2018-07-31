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

const runEndOfDay = pipeK(
	() => executeCommandInheritStdout("open -a Notes"),
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

runEndOfDay(Future.of()).fork(
	error => error && console.error, // eslint-disable-line no-console, no-undef
	() => {}
);

// Pending work on integrating with GitHub

// const readFile = Future.encaseN2(fs.readFile);
// const prompt = Future.encaseP(inquirer.prompt);
//
// const singlePrompt = promptDetails =>
// 	prompt({ ...promptDetails, name: "name" }).map(prop("name"));
//
// const gitHubTokenFilePath = path.resolve(__dirname, "./gitHubToken.secret");
//
// const askForAndStoreGitHubToken = () =>
// 	singlePrompt({
// 		type: "confirm",
// 		message:
// 			"You don't have a GitHub token set up. Would you like to create one now?",
// 		default: true,
// 	}).chain(
// 		createToken => (createToken ? openGitHubTokenPage() : Future.reject())
// 	);
//
// const getGitHubToken = () =>
// 	readFile(gitHubTokenFilePath, "utf8")
// 		.fold(
// 			error =>
// 				error.code == "ENOENT"
// 					? askForAndStoreGitHubToken()
// 					: Future.reject(error),
// 			() => console.log("hmm")
// 		)
// 		.chain(x => x);
//
// getGitHubToken()
// 	.map(token => console.log("will get data here"))
// 	.fork(error => error && console.error(error), () => {}); // eslint-disable-line no-console, no-undef

// https://developer.github.com/v4/guides/forming-calls/#authenticating-with-graphql
