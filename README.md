Jenkins.cfc
=======

Interact with Jenkins in your ColdFusion and Railo projects.

Notes

- Built to work with Jenkins 1.5.x.
- Tested on Railo 4.2.1 with full null support, and localmode set to modern, hence the lack of var scoped variables.

Todo

- Change getStringParameterNode() to use better XML manipulation. The current nested loops approach is damn ugly!