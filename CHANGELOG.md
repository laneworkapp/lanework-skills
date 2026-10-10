**October 2026**

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
