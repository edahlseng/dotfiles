/* @flow */

import { type Fluture as FutureMonad } from "fluture";
import { isEmpty } from "ramda";
import {
	fromCommand,
	executeCommandInheritStdout,
} from "@eric.dahlseng/cli-tools";

export const rebase = (
	remote: string,
	branch: string
): FutureMonad<mixed, void> =>
	executeCommandInheritStdout(`git fetch ${remote} ${branch}`).chain(() =>
		executeCommandInheritStdout(`git rebase ${remote}/${branch}`)
	);

export const hasGitRemote = (remoteName: string) =>
	fromCommand("git remote").map(remotes =>
		new RegExp(`^${remoteName}$`, "m").test(remotes)
	);

export const currentGitBranch = () =>
	fromCommand("git rev-parse --abbrev-ref HEAD").map(x => x.trim());

export const branchNeedsPush = () =>
	fromCommand("git rev-parse --is-inside-work-tree")
		.chain(() =>
			fromCommand(
				"git cherry -v origin/$(git symbolic-ref --short HEAD 2>/dev/null) 2>/dev/null | wc -l | bc"
			)
		)
		.map(numberOfUnpushedCommits => numberOfUnpushedCommits != 0);

export const originMissingRemoteBranch = ({
	currentBranch,
}: {
	currentBranch: string,
}) =>
	fromCommand(
		`git ls-remote --heads $(git remote get-url origin) ${currentBranch}`
	).map(remoteHead => isEmpty(remoteHead));

export const remoteUrl = (remoteName: string) =>
	fromCommand(`git remote get-url ${remoteName}`).map(x => x.trim());
