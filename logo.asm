
; GUESS THE NUMBER - at the beginning of the game
start_game db "   ___ _   _ ___ ___ ___   _____ _  _ ___   _  _ _   _ __  __ ___ ___ ___ ",13,10
db "  / __| | | | __/ __/ __| |_   _| || | __| | \| | | | |  \/  | _ ) __| _ \",13,10
db " | (_ | |_| | _|\__ \__ \   | | | __ | _|  | .` | |_| | |\/| | _ \ _||   /",13,10
db "  \___|\___/|___|___/___/   |_| |_||_|___| |_|\_|\___/|_|  |_|___/___|_|_\$",13,10
                                                                          


; GAME OVER - at the ending of the game
game_over db "   ___   _   __  __ ___    _____   _____ ___ ",13,10
db "  / __| /_\ |  \/  | __|  / _ \ \ / / __| _ \",13,10
db " | (_ |/ _ \| |\/| | _|  | (_) \ V /| _||   /",13,10
db "  \___/_/ \_\_|  |_|___|  \___/ \_/ |___|_|_\$" ,13,10



; YOU WON ! - when the user won in that certain round
win db " __   _____  _   _  __      _____  _  _   _ ",13,10
db " \ \ / / _ \| | | | \ \    / / _ \| \| | | |",13,10
db "  \ V / (_) | |_| |  \ \/\/ / (_) | .` | |_|",13,10
db "   |_| \___/ \___/    \_/\_/ \___/|_|\_| (_)$",13,10



; YOU LOST ! - when the user lost in that certain round
lose db " __   _____  _   _   _    ___  ___ _____   _ ",13,10
db " \ \ / / _ \| | | | | |  / _ \/ __|_   _| | |",13,10
db "  \ V / (_) | |_| | | |_| (_) \__ \ | |   |_|",13,10
db "   |_| \___/ \___/  |____\___/|___/ |_|   (_)$",13,10



; HELP - the rules
help_tries db "you have 10 tries$"
help_guess db "you can guess only numbers between 1-255$"
help_name db "your name is up to 10 characters$"
help_good_luck db "GOOD LUCK !$"



computer_logo db "               ________________________________________________",13,10
db "              /                                                \",13,10
db "             |    _________________________________________     |",13,10
db "             |   |                                         |    |",13,10
db "             |   |  C:\> _                                 |    |",13,10
db "             |   |            Press S to START             |    |",13,10
db "             |   |                                         |    |",13,10
db "             |   |            Press H for HELP             |    |",13,10
db "             |   |                                         |    |",13,10
db "             |   |            Press E to EXIT              |    |",13,10
db "             |   |                                         |    |",13,10
db "             |   |                                         |    |",13,10
db "             |   |                                         |    |",13,10
db "             |   |                                         |    |",13,10
db "             |   |                                         |    |",13,10
db "             |   |                                         |    |",13,10
db "             |   |_________________________________________|    |",13,10
db "             |                                                  |",13,10
db "              \_________________________________________________/",13,10
db "                     \___________________________________/",13,10
db "                  ___________________________________________",13,10
db "               _-'    .-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.  --- `-_",13,10
db "           _-'.-.-. .---.-.-.-.-.-.-.-.-.-.-.-.-.-.-.--.  .-.-.`-_",13,10
db "         _-'.-.-.-. .---.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-`__`. .-.-.-.`-_",13,10
db "      _-'.-.-.-.-. .-----.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-----. .-.-.-.-.`-_",13,10
db "   _-'.-.-.-.-.-. .---.-. .-------------------------. .-.---. .---.-.-.-.`-_",13,10
db "  :-------------------------------------------------------------------------:",13,10
db "  `---._.-------------------------------------------------------------._.---'$",13,10



smiley_logo db "                                 *****************",13,10
db "                            ******               ******",13,10
db "                        ****                           ****",13,10
db "                     ****                                 ***",13,10
db "                    ***                                       ***",13,10
db "                  **           ***               ***           **",13,10
db "                **           *******           *******          ***",13,10
db "                **            *******           *******            **",13,10
db "              **             *******           *******             **",13,10
db "              **               ***               ***               **",13,10
db "             **                                                     **",13,10
db "             **       *                                     *       **",13,10
db "             **      **                                     **      **",13,10
db "              **   ****                                     ****   **",13,10
db "              **      **                                   **      **",13,10
db "               **       ***                             ***       **",13,10
db "                ***       ****                       ****       ***",13,10
db "                  **         ******             ******         **",13,10
db "                   ***            ***************            ***",13,10
db "                     ****                                 ****",13,10
db "                        ****                           ****",13,10
db "                            ******               ******",13,10
db "                                 *****************",13,10
db "                              *Press any key to start*$",13,10



