#!/usr/env/node

/* @flow */

import { pipeK } from "ramda";
import Future from "fluture";

import { StdLog } from "./monoids.js";
import Writer from "./writer.js";
import State from "./state.js";
import {
	determineConfiguration as determineConfigurationSF,
	rebaseProject as rebaseProjectSF,
	runChecks as runChecksSF,
	updateRemote as updateRemoteSF,
	openPullRequest as openPullRequestSF,
} from "./steps.js";

// -----------------------------------------------------------------------------
// Main Application Monad Setup
// -----------------------------------------------------------------------------

const StateFuture = State.StateT(Future);
const App = Writer.WriterT(StateFuture, StdLog);

// App helpers
const label = x => App.log(`\n${x}\n`);
const fromStateFuture = fn => x => App.lift(fn(x));

// Convert Future-returning functions to App-returning functions
const determineConfiguration = fromStateFuture(determineConfigurationSF);
const rebaseProject = fromStateFuture(rebaseProjectSF);
const runChecks = fromStateFuture(runChecksSF);
const updateRemote = fromStateFuture(updateRemoteSF);
const openPullRequest = fromStateFuture(openPullRequestSF);

// -----------------------------------------------------------------------------
// Actions
// -----------------------------------------------------------------------------

const preparePullRequest = pipeK(
	determineConfiguration,
	label("Rebasing..."),
	rebaseProject,
	label("Running checks..."),
	runChecks,
	label("Updating remote..."),
	updateRemote,
	label("Opening pull request..."),
	openPullRequest
);

// -----------------------------------------------------------------------------
// Run
// -----------------------------------------------------------------------------

preparePullRequest(App.of())
	.run()
	.evalState({ workingDirectory: process.cwd() })
	.fork(
		error => error && console.error, // eslint-disable-line no-console, no-undef
		() => {}
	);
