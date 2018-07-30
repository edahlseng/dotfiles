#!/usr/env/node

import fs from "fs";
import util from "util";
import inquirer from "inquirer";
import { prop } from "ramda";
import Future from "fluture";
import applescript from "applescript";
import childProcess from "child_process";

import secrets from "./secrets.json";

const runApplescript = util.promisify(applescript.execString);

async function getPendingNotes() {
	const results = await runApplescript(
		'tell application "Notes" to get {id, name, body} of notes in folder "Notes"'
	);
	const pendingNotes = [];
	for (let idx = 0; idx < results.length; idx++) {
		pendingNotes.push({
			id: results[0][idx],
			name: results[1][idx],
			body: results[2][idx],
		});
	}
	return pendingNotes;
}

const stateFilePath = `${__dirname}/state.json`;

function getCurrentState() {
	return Future((reject, resolve) => {
		fs.readFile(stateFilePath, (err, data) => {
			if (err) {
				return resolve({ inProgress: false, lastCompletedReview: "never" });
			}
			return resolve(JSON.parse(data));
		});
	});
}

const stateOrder = [
	"budget",
	"email",
	"calendar",
	"notes",
	"reminders",
	"files",
];

const stateAction = {
	budget: Future((reject, resolve) =>
		resolve(
			childProcess.spawn("open", secrets.budgetLinks, {
				detached: true,
			})
		)
	),
	calendar: Future((reject, resolve) =>
		resolve(childProcess.spawn("open", ["-a", "Calendar"], { detached: true }))
	),
	files: Future((reject, resolve) =>
		resolve(
			childProcess.spawn("open", ["~/Downloads", "~/Desktop"], {
				detached: true,
			})
		)
	),
	notes: Future((reject, resolve) =>
		resolve(childProcess.spawn("open", ["-a", "Notes"], { detached: true }))
	),
	reminders: Future((reject, resolve) =>
		resolve(childProcess.spawn("open", ["-a", "Reminders"], { detached: true }))
	),
	email: Future((reject, resolve) =>
		resolve(childProcess.spawn("open", ["-a", "Mail"], { detached: true }))
	),
};

const prompt = Future.encaseP(inquirer.prompt);
const readFile = Future.encaseN2(fs.readFile);
const writeFile = Future.encaseN3(fs.writeFile);
const caseOf = cases => control => cases[control];
const jsonParse = Future.encase(JSON.parse);

const singlePrompt = promptDetails =>
	prompt({ ...promptDetails, name: "name" }).map(prop("name"));

const nextState = currentState =>
	stateOrder[stateOrder.indexOf(currentState) + 1];

const updateStateFile = currentState =>
	readFile(stateFilePath, "utf8")
		.chain(jsonParse)
		.fold(
			() =>
				writeFile(
					stateFilePath,
					JSON.stringify({
						inProgress: true,
						lastCompletedReview: "never",
						currentState,
					}),
					"utf8"
				),
			savedState =>
				writeFile(
					stateFilePath,
					JSON.stringify({
						...savedState,
						inProgress: true,
						currentState,
					}),
					"utf8"
				)
		)
		.chain(x => x);

function review(currentState = "budget") {
	return updateStateFile(currentState)
		.chain(() =>
			singlePrompt({
				type: "input",
				message: `The current step is ${currentState}. Do you want to begin (b), mark it as done (d), or pause this review (p)?`,
				filter: x => (["b", "d", "p"].includes(x) ? x : ""),
			})
		)
		.chain(
			caseOf({
				p: Future.reject(),
				b: stateAction[currentState].map(() => currentState),
				d: Future.of(nextState(currentState)),
			})
		)
		.chain(nextState => (nextState ? review(nextState) : Future.of()));
}

function startReview() {
	return getCurrentState()
		.chain(
			savedState =>
				savedState.inProgress
					? singlePrompt({
							type: "input",
							message: `You have a review in progress (current state is ${
								savedState.currentState
							}). Do you want to continue (c), restart (r), or do nothing (n)?`,
							filter: x => (["c", "r", "n"].includes(x) ? x : ""),
					  }).chain(
							caseOf({
								c: Future.of(savedState.currentState),
								r: Future.of(),
								n: Future.reject(),
							})
					  )
					: singlePrompt({
							type: "confirm",
							message: `Your last review was ${
								savedState.lastCompletedReview
							}. Do you want to start a new review?`,
							default: true,
					  }).chain(start => (start ? Future.of() : Future.reject()))
		)
		.chain(review);
}

startReview().fork(error => error && console.error(error), () => {}); // eslint-disable-line no-console, no-undef
