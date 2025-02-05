# Avant Plugin
Avant Plugin is a Roblox Studio plugin for running unit tests. For the base
library to create custom runners, see [Avant-Runtime](https://github.com/Avant-Rbx/Avant-Runtime).

This is the successor to [Nexus Unit Testing Plugin](https://github.com/TheNexusAvenger/Nexus-Unit-Testing-Plugin).

⚠️ At the moment, only [TestEZ](https://github.com/Roblox/testez) is supported.
See [Avant-Runtime](https://github.com/Avant-Rbx/Avant-Runtime)'s README for more.

## Paid Version
Avant is sold as a paid plugin. In order to use the plugin, it is expected
to pay for a version from one of the following:
- [Itch](https://thenexusavenger.itch.io/avant-plugin)
- [Roblox Creator Marketplace](https://create.roblox.com/store/asset/11039022908/)

Itch has the option to pay what you want beyond the minimum, while Roblox
only offers a fixed price.

When a non-paid version of the plugin is used (such as the GitHub release or
built with Rojo), a message will be displayed about purchasing a paid version.
This message can be dismissed and won't re-appear for 30 days.

## Writing Tests
For TestEZ, [see TestEZ's docs](https://roblox.github.io/testez/getting-started/writing-tests/).

In order for tests to be detected, the name of the `ModuleScript` must
end with `.spec`.

## Runing Tests
In the plugins tab in Roblox Studio, there will be a button named
"Unit Tests". The button toggles a window named "Unit Tests" that
displays all the `ModuleScript`s that end with `.spec` in the name.
There are 3 buttons for running tests:
- All: Runs all tests.
- Failed: Runs all failed tests, or all if there are no failed tests.
- Selected: Runs all selected tests, or all if there are no selected tests.

Tests may also have indicators added to the test state icon:
- Blue dot: the test has output (`print`s, `warn`s, or errors).
- Yellow dot: the contents of the test were updated since the last run.
- Red dot: the `ModuleScript` test was removed.

Any test can be double-clicked to focus the output in a window named
"Test Output". The window will appear any time a test output is focused.

## License
Avant Plugin is available under the terms of the MIT License. See
[LICENSE](LICENSE) for details.