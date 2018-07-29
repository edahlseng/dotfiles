/* @flow */

import path from "path";
import { pipe, assoc, isNil } from "ramda";
import Future, { type Fluture as FutureMonad } from "fluture";
import {
	asFutureValues,
	loadJson,
	condF,
	trueF,
	singlePrompt,
	fileExists,
	executeCommandInheritStdout,
} from "@eric.dahlseng/cli-tools";

import State from "./state.js";
import { assocObject } from "./utils.js";
import {
	hasGitRemote,
	currentGitBranch,
	rebase,
	branchNeedsPush,
	originMissingRemoteBranch,
	remoteUrl,
} from "./git.js";

// Helpers
const run = executeCommandInheritStdout; // This command is used many times, so use a shorter name in order to improve readability
const chain = fn => x => x.chain(fn);
const chainRej = fn => x => x.chainRej(fn);
const mapRej = fn => x => x.mapRej(fn);

const StateFuture = State.StateT(Future);

// StateFuture helpers
const addToState = function(additionalState) {
	return StateFuture.modify(assocObject(additionalState));
};

// eslint-disable-next-line no-unused-vars
const withStateFromFuture = fn => (x: *) =>
	StateFuture.get().chain(config => StateFuture.lift(fn(config)));

// -----------------------------------------------------------------------------
// Configuration
// -----------------------------------------------------------------------------

const pullRequestUrl: ({
	currentBranch: string,
	upstreamRemoteName: string,
}) => FutureMonad<mixed, string> = pipe(
	({ currentBranch, upstreamRemoteName }) =>
		Future.parallel(Infinity, [
			remoteUrl("origin").map(
				url =>
					url.replace(/^.*:/, "").replace(/\/.*$/, "") + `:${currentBranch}`
			),
			remoteUrl(upstreamRemoteName).map(url =>
				url
					.replace(/git@github\.com:/, "https://github.com/")
					.replace(".git", "")
			),
		]).map(
			([pullRequestBase, targetGitHubUrl]) =>
				`${targetGitHubUrl}/compare/master...${pullRequestBase}`
		)
);

const determineConfigurationF = pipe(
	() =>
		asFutureValues({
			hasRemoteNamedUpstream: hasGitRemote("upstream"),
			hasRemoteNamedOrigin: hasGitRemote("origin"),
			currentBranch: currentGitBranch(),
		}),
	chain(
		config =>
			config.hasRemoteNamedUpstream || config.hasRemoteNamedOrigin
				? Future.of(config)
				: Future.reject(
						"Could not find an upstream remote to submit a pull request against."
				  )
	),
	// TODO: I wonder if there's a way to clean up the combination of these two together, maybe with an applicative or lift or something?
	chain(config =>
		pullRequestUrl({
			currentBranch: config.currentBranch,
			upstreamRemoteName: config.hasRemoteNamedUpstream ? "upstream" : "origin",
		}).map(url => assoc("pullRequestUrl", url, config))
	)
);

export const determineConfiguration = (x: *) =>
	StateFuture.lift(determineConfigurationF(x)).chain(addToState);

// -----------------------------------------------------------------------------
// Rebase
// -----------------------------------------------------------------------------

const rebaseProjectF = (config: {
	hasRemoteNamedUpstream: boolean,
	currentBranch: string,
}) =>
	rebase(
		config.hasRemoteNamedUpstream ? "upstream" : "origin",
		"master"
	).mapRej(() => "");

export const rebaseProject = withStateFromFuture(rebaseProjectF);

// -----------------------------------------------------------------------------
// Run Checks
// -----------------------------------------------------------------------------

type runNPMChecksFFn = ({ workingDirectory: string }) => Future<Error, empty>;
const runNPMChecksF: runNPMChecksFFn = pipe(
	config => path.resolve(config.workingDirectory, "package.json"),
	loadJson,
	mapRej(() => null),
	(chain(
		packageJson =>
			packageJson.scripts.check ? run("npm run check") : Future.of()
	): Object => Future<Error, empty>),
	chainRej(err => (isNil(err) ? Future.of() : Future.reject(err)))
);

const runNPMChecks = withStateFromFuture(runNPMChecksF);

const runInfrastructureChecksF = pipe(
	condF([
		[
			config =>
				fileExists(path.resolve(config.workingDirectory, "bin/covalence")),
			() => run("bin/covalence ci"),
		],
		[
			config =>
				fileExists(
					path.resolve(config.workingDirectory, "infra/bin/covalence")
				),
			() => run("infra/bin/covalence ci"),
		],
		[trueF, Future.of],
	]),
	chain(x => x)
);

const runInfrastructureChecks = withStateFromFuture(runInfrastructureChecksF);

export const runChecks = pipe(
	runNPMChecks,
	chain(runInfrastructureChecks)
);

// -----------------------------------------------------------------------------
// Update Remote
// -----------------------------------------------------------------------------

const requestPushBranch = config =>
	singlePrompt({
		type: "confirm",
		message:
			"The origin remote does not have your current local branch. Would you like to push this branch to origin?",
		default: true,
	}).chain(
		push =>
			push
				? run(`git push --set-upstream origin ${config.currentBranch}`)
				: Future.reject()
	);

const requestForcePush = () =>
	singlePrompt({
		type: "confirm",
		message: "There are unpushed changes. Would you like to force push?",
		default: true,
	}).chain(push => (push ? run(`git push --force`) : Future.reject()));

const updateRemoteF = pipe(
	condF([
		[originMissingRemoteBranch, requestPushBranch],
		[branchNeedsPush, requestForcePush],
		[trueF, Future.of],
	]),
	chain(x => x)
);

export const updateRemote = withStateFromFuture(updateRemoteF);

// -----------------------------------------------------------------------------
// Open Pull Request
// -----------------------------------------------------------------------------

const openPullRequestF = ({ pullRequestUrl }: { pullRequestUrl: string }) =>
	run(`open ${pullRequestUrl}`);

export const openPullRequest = withStateFromFuture(openPullRequestF);
