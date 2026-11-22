**November 2026**

Version 0.10.0: a wrong call to any script now exits 2 and a refusal exits 1, and every script's header states its exit codes.

Agents can now add labels to a card with a new label-card script, and filing a card takes labels too.

Moving a card no longer leaves a comment behind when the move is refused.

Names, models and session ids holding quotes, braces, colons or backslashes are now written correctly, and unwritable values are refused before anything is saved.

A lease write is no longer lost when a lease script is killed mid-write, and another user's write in progress is left alone.

A card lease no longer stops renewing when the card is moved between lanes while it is held.

Leases now refuse session ids they cannot store faithfully.

Board checks now follow linked lanes, report each card once, and keep each finding on one line.

Board commits that push now send a commit an interrupted run left behind and fail fast when git asks for a password.

Settling a discovery question no longer takes your click on Recap for the answer, and a refused settle now says why.

/lanework:watch now stops with a clear message when fswatch is not installed, instead of ending silently.

Version 0.9.0: the dispatch skill is retired; use /lanework:watch instead, which now catches up when it starts.

Sessions now take a lease on a card before working it, so two sessions no longer work the same card at once, and a lease left behind expires on its own.

/lanework:watch now reads the app's record of a card move to tell who moved the card.

Cards that wait on something only you can do, such as running a trial or cutting a release, now get a clear request to you and show as waiting.

Question, ticket and decision cards filed on a board whose app shows card citations now carry a citation such as Q3, T2 or ADR1 in place of a number in the title, and links to a card are labelled with it.

Agents now file, move and commit cards with ready-made scripts, so moves show who made them and board commits leave your other files alone.

/lanework:watch now answers comments you left while no watch was running, in every lane except Done, and reports work claims that look abandoned.

/lanework:watch now re-reads your boards after its conversation is compacted, instead of trusting its summary.

If you installed the skills by hand, remove the old link with rm ~/.claude/skills/dispatch.

Questions the skills ask now go to anyone on a board by default, so every person on a shared board gets the answer buttons, and they name one person only when the question is theirs alone.

Healing a board no longer lets an agent sign its work as "anyone", a name Lanework keeps for addressing every person.

An agent can now clear a card's waiting mark after you rule outside the board, and a new check lists every such clear.

A new check finds cards that two sessions started work on at the same time.

When a board commit's hook fails or its push is rejected, your own staged changes are now kept exactly as they were.

Discovery no longer settles or parks a question that is waiting on you unless your answer is recorded on the card.

Discovery now records an answer you give in chat in the same quoted format as the work skill, so it counts as an answer.

Asks addressed to one person by their handle are now checked like any other ask.

A card whose text contains three closing braces no longer stops scripts from writing to it.

Citation numbers on older boards no longer collide after a zero-padded or hand-typed citation.

The board checks now stop with an error, instead of reporting a clean board, when part of the board can't be read.

Skills now follow version 118 of Lanework's agent guide.

Version 0.8.0: cards, tickets and decision records the skills file now pick up the default labels of the lane they land in.

Existing plugin users: Lanework now installs from a central marketplace, so run `/plugin marketplace remove lanework` (it also uninstalls the plugin), then `/plugin marketplace add https://github.com/laneworkapp/lanework-marketplace.git`, then `/plugin install lanework@lanework`.

/dispatch now answers comments you left while no watch was running, in every lane except Done, and reports work claims that look abandoned.

A decision record that replaces an older one now links to it with a supersedes relation.

Merging a board now merges relations between cards the same way it merges comments.

/heal now checks the relations on a card.

/heal no longer suggests or migrates a Component label kind, since Lanework no longer builds it in.

A question on a card can now be addressed to several people at once.

Settling a question or resolving a ticket that waits on several people now clears its waiting mark completely.

Comments and cards the skills write are now always stamped with the time read from the clock.

When an agent shapes a card, it now gives it a label from the kind its lane is grouped by.

Reviewer verdicts are now written as plain Markdown, so they read properly on the card.

The discovery map now marks questions being asked with 💬 and those not yet askable with ⏳.

Skills now follow version 114 of Lanework's agent guide.

**October 2026**

Version 0.7.0: a new dispatch skill, started with /lanework:dispatch, watches your boards and hands each change to a fresh agent, so long watches stay fast.

Questions on a card that offer options now end with a Recap button that asks the agent to explain them in plain terms first.

Boards, tickets and decision records the skills write now use the compact layout Lanework writes, so /heal has nothing to tidy.

/heal now tidies lists and settings written in an older, spread-out layout.

Merging a board now keeps its labels and settings in the compact layout.

/heal now reads a rank written as text, such as "2", the way Lanework does.

/heal no longer accepts --global, since Lanework stopped reading machine-wide default labels.

The Type label kind on new boards now shows a cube icon.

Skills now follow version 101 of Lanework's agent guide.

When /heal finds a card with several values of a one-value label kind, it now keeps the one Lanework shows (the lowest rank) instead of the first in the file.

Version 0.6.0: a new plan skill, started with /lanework:plan, charts a big idea's open decisions as tickets on a board and settles one per session.

When the skills are installed by hand, a running /watch now picks up changes to them without being restarted.

Version 0.5.0: lanes on new pipeline, design loop and discovery boards now start with their own icons, tinted only where a lane waits on you.

When /heal updates a lane's description, it now keeps your own notes intact, including lists and code blocks.

Skills now follow version 84 of Lanework's agent guide.

Version 0.4.0: new boards can start with common label kinds (priority, component, type, size, platform, release, epic and round), chosen when the board is founded.

Each kind of board now comes with sensible default label kinds, and discovery boards always keep their round label.

Skills now follow version 83 of Lanework's agent guide, where a lane can group its cards by any label.

Version 0.3.0: a new heal skill, started with /heal, brings your existing boards up to date after showing you every change first.

Every lane now says who acts on it and what starts them, so agents no longer stall on a card you approved.

Ideas, Issues and Tasks now hold cards until you move them on, and agents start work unasked only in Shaping, Approved and Active.

A board watch now picks up approved cards that were already waiting when it started.

Discovery now records each decision as a card in a Decisions lane on its board, instead of a file in your repository.

Board scripts now refuse to run without a model name instead of signing your board as "unknown", and keep backslashes in card titles.

Version 0.2.2: agents now move a finished proposal from Shaping to Proposed themselves, instead of leaving that move to you.

A question you ask on a card another session owns is now answered on the card, never in chat.

Version 0.2.1: installing the plugin no longer needs a GitHub SSH key, since it now downloads over HTTPS.

Version 0.2.0: the pitlane skill is now called work, and pitwall is now called watch, started with /watch.

A new merge skill settles git conflicts on a shared board, keeping both sides' edits and stopping only when text would otherwise be lost.

The lanework skill can heal a damaged board, repairing label, stamp and title problems after a dry run.

Boards now live in a Lanework folder, and an older Pitlane folder is still found and offered a rename.

Skills follow version 82 of Lanework's agent guide, where priority and component are labels.

New boards keep every lane's description instead of leaving most of them empty.

Version 0.1.0: the skills install as one Claude Code plugin and update only when a tested release ships.

Skills follow version 78 of Lanework's agent guide.

New pipeline boards include a Tasks lane, where chores you file are built straight away without shaping or review.

Any choice only you can make now arrives on its card as a question with options, and nothing that depends on it is built until you answer.

**September 2026**

Skills follow version 77 of Lanework's agent guide, and leave tracker settings untouched while tracker sync is off.

The lanework-boards skill is now called lanework.

Pitwall can watch several boards at once, and runs only when you start it.

Pitlane can run a build team for a batch of cards, with an independent review when the work calls for one.

The discovery skill examines a project's problem and domain space on its own board, and turns your rulings into ADRs and PDRs.

Questions from agents arrive as their own short comments with answer buttons, instead of at the end of long notes.

The lanework-boards, pitlane and pitwall skills read, found, sweep and watch Lanework boards.
