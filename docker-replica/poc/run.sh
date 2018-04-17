mkdir -p $HOME/ws/data/rs{1,2,3}
nohup ./bootstrap.sh dev repl1 28017 repl1 28017 $HOME/ws/data/rs1 &
nohup ./bootstrap.sh dev repl2 28018 repl1 28017 $HOME/ws/data/rs2 &
nohup ./bootstrap.sh dev repl3 28019 repl1 28017 $HOME/ws/data/rs3 &

