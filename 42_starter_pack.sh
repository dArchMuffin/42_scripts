#!/bin/bash

REPO=$1
NAME=$2

git clone $REPO $NAME

while [[ ! -d "$NAME" ]]; do
  sleep 1
done

cd $NAME

# cloner un git blueprint 
# puis copier son contenu dans $NAME
# puis editer chaque fichier avec $NAME
mkdir src
mkdir include
mkdir bin

touch src/$NAME.c
touch include/$NAME.h
touch Makefile
touch .gitignore

echo ".gitignore" > .gitignore
echo "bin" >> .gitignore
echo "obj" >> .gitignore
echo "$NAME" >> .gitignore

/sgoinfre/oelleaum/nvim/bin/nvim "Makefile" -c "Stdheader" -c "wq"
/sgoinfre/oelleaum/nvim/bin/nvim "src/$NAME.c" -c "Stdheader" -c "wq"
/sgoinfre/oelleaum/nvim/bin/nvim "include/$NAME.h" -c "Stdheader" -c "wq"

#.h blueprint
NAME_UP=$(echo "$NAME" | tr '[:lower:]' '[:upper:]') 
echo "#ifndef \'$NAME_UP\'_H
# define \'$NAME_UP\'_H

//$NAME.c

#endif" >> include/$NAME.h
#.c blueprint
echo "
#include \"$NAME.h\"

int $NAME(void)
{

  return (0);
}" >> src/$NAME.c

echo "NAME=$NAME
#BONUS_NAME=$(echo $NAME)_bonus

CC=cc
FLAGS=-Wall -Werror -Wextra
INC=-I include
INC_LIBFT=-I libft/include
#INC_BONUS=-I bonus/include

SRC_DIR=src
OBJ_DIR=obj

LIBFT_SRC_DIR = libft/src
LIBFT_OBJ_DIR = libft/obj
#BONUS_SRC_DIR = bonus/src

LIBFT_SRC_FILES = \\
    libft/src/ft_atoi.c \\
    libft/src/ft_bzero.c \\
    libft/src/ft_calloc.c \\
    libft/src/ft_isalnum.c \\
    libft/src/ft_isalpha.c \\
    libft/src/ft_isascii.c \\
    libft/src/ft_isdigit.c \\
    libft/src/ft_isprint.c \\
    libft/src/ft_itoa.c \\
    libft/src/ft_lstadd_back_bonus.c \\
    libft/src/ft_lstadd_front_bonus.c \\
    libft/src/ft_lstclear_bonus.c \\
    libft/src/ft_lstdelone_bonus.c \\
    libft/src/ft_lstiter_bonus.c \\
    libft/src/ft_lstlast_bonus.c \\
    libft/src/ft_lstnew_bonus.c \\
    libft/src/ft_lstsize_bonus.c \\
    libft/src/ft_memchr.c \\
    libft/src/ft_memcmp.c \\
    libft/src/ft_memcpy.c \\
    libft/src/ft_memmove.c \\
    libft/src/ft_memset.c \\
    libft/src/ft_putchar_fd.c \\
    libft/src/ft_putendl_fd.c \\
    libft/src/ft_putnbr_fd.c \\
    libft/src/ft_putstr_fd.c \\
    libft/src/ft_split.c \\
    libft/src/ft_strdup.c \\
    libft/src/ft_strchr.c \\
    libft/src/ft_striteri.c \\
    libft/src/ft_strjoin.c \\
    libft/src/ft_strlcat.c \\
    libft/src/ft_strlcpy.c \\
    libft/src/ft_strmapi.c \\
    libft/src/ft_strnstr.c \\
    libft/src/ft_strrchr.c \\
    libft/src/ft_strtrim.c \\
    libft/src/ft_substr.c \\
    libft/src/ft_strlen.c \\
    libft/src/ft_strncmp.c \\
    libft/src/ft_tolower.c \\
    libft/src/ft_toupper.c \\
    libft/src/ft_split.c \\
    libft/src/get_next_line.c \\
    libft/src/get_next_line_utils.c

LIBFT_OBJ_FILES = \$(LIBFT_SRC_FILES:.c=.o)

OBJ_FILES = \$(SRC_FILES:.c=.o)
OBJ = \$(addprefix \$(OBJ_DIR)/,\$(OBJ_FILES))
BONUS = \$(addprefix \$(BONUS_OBJ_DIR)/,\$(BONUS_OBJ_FILES))

LIBFT_A = libft/libft.a

GREEN=\033[32m
RED=\033[31m
RESET=\033[0m

all: \$(NAME)

\$(NAME): \$(OBJ) \$(LIBFT_A) Makefile libft/Makefile libft/include/libft.h
	\$(CC) \$(CFLAGS) \$(OBJ) \$(LIBFT_A) \$(LIBFT_FLAGS) -o \$(NAME)
	@echo 
	@echo '\$(GREEN)compilation successful ✅ \$(NAME)\$(RESET)'
	@echo 

\$(LIBFT_A): \$(LIBFT_SRC_FILES) FORCE
	@\$(MAKE) --no-print-directory -C libft

\$(OBJ_DIR)/%.o: %.c Makefile ./include/fractol.h
	@mkdir -p \$(dir \$@)
	\$(CC) \$(CFLAGS) \$(INC) \$(INC_LIBFT) -I . -c \$< -o \$@


bonus: \$(BONUS_NAME)

\$(BONUS_OBJ_DIR)/%.o: bonus/src_bonus/%.c ./bonus/include_bonus/fractol_bonus.h
	@mkdir -p \$(dir \$@)
	\$(CC) \$(CFLAGS) \$(INC_BONUS) -c \$< -o \$@

\$(BONUS_NAME): \$(BONUS_OBJ_FILES) \$(LIBFT_A) Makefile libft/Makefile ./bonus/include_bonus/fractol_bonus.h
	\$(CC) \$(CFLAGS) \$(BONUS_OBJ_FILES) \$(LIBFT_A) \$(LIBFT_FLAGS) -o \$(BONUS_NAME)
	@echo
	@echo '\$(GREEN)compilation successful ✅ \$(BONUS_NAME)\$(RESET)'
	@echo

clean:
	rm -rf \$(OBJ_DIR)/*

fclean: clean
	rm -f \$(NAME) \$(BONUS_NAME)
	rm -f \$(LIBFT_A)

re: fclean all

FORCE:
.PHONY: all re clean fclean bonus" >> Makefile

