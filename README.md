# 42_scripts
A set of simple bash scripts for 42 cursus.

From little automations scripts to full testers for your projects

---

### 42_starter_pack.sh
Clones your freshly created 42 repository, and creates common folders and files for 42 projects.
Use :
```bash
./42_start_pack.sh <repo_git> <project_name>
```

### rename_bonus.sh 
Make sure to first mkdir "bonus" and put all your bonus files inside, then run in your project folder :
```bash
./rename_bonus.sh
```
in case of error, try :
```bash
bash rename_bonus.sh
```

### eval.sh (Ongoing)
To run at start of an evaluation to check norm, project name and compiling with makefile.
```bash
./eval.sh <repo_to_clone> <project_name>
```

### alias_manager.sh 
To list and add easily aliases
```bash
./alias_manager.sh add <alias> <exec>
./alias_manager.sh list
./alias_manager.sh rm <alias>
```

### code_metrics (ongoing)
To get infos on your projects files (comments, lines of code ...)

Run in your project folder :
```bash
./code_metrics.sh
```

### doc_generator (ongoing)
To implemente your documentation all along your code workflow.

Run in your project folder :
```bash
./doc_generator.sh
```

### push_swap_tester (ongoing)
Trying to centralized my scripts used to test my push_swap project

Work in progres ...

Run in your project folder :
```bash
./push_swap_tester.sh
```

### pipex_tester (ongoing)
Building a tester for my pipex project from the start of the project : experimenting Test Driven Developpment

Work in progress ...

---

# Contributing

Feel free to contribute to this collection of scripts by submitting pull requests or creating issues.
