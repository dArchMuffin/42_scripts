#!/bin/sh

INPUT=$1

MYSHELL_FILE=$(failed_tests/$INPUT/myshell)
BASH_FILE=$(failed_tests/$INPUT/bash)
LEAKS_FILE=$(failed_tests/$INPUT/leaks)

BASH_OUTPUT=$(echo -e "$INPUT" | bash)
MINISHELL_OUTPUT=$(echo -e "$INPUT" | ./Minishell/minishell | grep -v '^\[Minishell\]\$')
# VALGRIND_MINISHELL_OUTPUT=$(echo -e "$INPUT" | valgrind --check-leak=full ./Minishell/minishell | grep -v '^\[Minishell\]\$')

 

echo -e "========== $INPUT =========="
echo -e $MINISHELL_OUTPUT # > $TEST"_minishell"
echo -e $BASH_OUTPUT # > $TEST"_bash"

 # integrer 
 #   exit codes
 #   stderr
 #   file output
 #
 #   leaks tests
 #   zombies process
 #   fd closed
 
# if output || stderr || exit codes || file output 
# if [[ $(diff -q $MINISHELL_OUTPUT $BASH_OUTPUT) ]]; then
  # echo "KO : $INPUT"
  # echo "Minishell Stdout : $MINISHELL_STDOUT"
  # echo "Bash Stdout : $BASH_STDOUT"
  # echo "Minishell Stderr : $MINISELL_STDERR"
  # echo "Bash Stderr : $BASH_STDERR"
  # echo "Minishell exit code : $MINISELL_EXIT_CODE"
  # echo "Bash exit code : $BASH_EXIT_CODE"
  # mkdir failed_tests/$INPUT
  # touch $MYSHELL_FILE
  # touch $BASH_FILE
  # echo "Minishell Stdout : $MINISHELL_STDOUT" >> failed_tests/$INPUT/mys
  # echo "Bash Stdout : $BASH_STDOUT" >> failed_tests
  # echo "Minishell Stderr : $MINISELL_STDERR" >> failed_tests
  # echo "Bash Stderr : $BASH_STDERR" >> failed_tests
  # echo "Minishell exit code : $MINISELL_EXIT_CODE" >> failed_tests
  # echo "Bash exit code : $BASH_EXIT_CODE" >> failed_tests
# else if leaks == 0 
#    echo "OK : $TEST"
# fi
# if leaks == 1
#   echo "LEAKS !"
#   echo $VALGRIND_MINISHELL_OUTPUT > $LEAKS_FILE
# leaks tests
 #zombies process
 #fd closed

mkdir failed_tests

#test_my_shell  "Input"
#test_my_shell  "Input"
#test_my_shell  "Input"
#test_my_shell  "Input"
#test_my_shell  "Input"
#test_my_shell  "Input"




# si un fichier existe dans failed_tests :
#   KO : grep input
#   Leaks : grep input
#   Save log ?
#     cp -r failed_tests log/test#$(ls log -l | wc -l)
#      boucle : si un fichier est vide on le supprime 
#      boucle : si un dossier est cide on le suprime
# sinon
#   echo Well done !
#
# rm -rf failed_tests
#
#
# 
#
#
#
#
 # Tests
 #    ls
 #      stdout
 #        bash
 #        myshell
 #      fileout
 #        bash
 #        myshell
 #      stderr
 #        bash
 #        myshell
 #      exit_code
 #        bash
 #        myshell
 #      leaks
 #    cd
 #      stdout
 #        bash
 #        ..
 #       ..
 #    echo
 #    ..
 #    ..
 #

