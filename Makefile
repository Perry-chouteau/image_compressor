##
## EPITECH PROJECT, 2022
## Makefile
## File description:
## Makefile of image compressor
##

BIN_PATH		:=	$(shell stack path --local-install-root)

NAME			=	imageCompressor

all:
	stack build
	cp $(BIN_PATH)/bin/$(NAME)-exe ./$(NAME)

clean:
	stack clean

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re