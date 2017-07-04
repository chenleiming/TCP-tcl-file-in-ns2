# TCP-tcl-file-in-ns2 

#1、cubic-dv-fattree-k4.tcl 仿真TCP cubic，dv是ns2中的一种路由算法，可实现最短路径。
文件中拓扑为k=4的fattree拓扑结构，16个主机既是数据发送端也是数据接收端，同时模拟16条一对一的TCP流，无网络瓶颈，并记录cwnd和部分queue,queue文件第一列为time ，第五列为瞬时队列长度，可使用命令把这两列提取到一个新文件中：awk '{print $1,$5}' queue1.tr >newfile。
变量enableALL为1 ，可记录仿真发生的所有数据传递事件，并记录在tcp-all.tr文件中，变量ecn为1 时可实现ECN机制。

#2、cubic-nix-fattree-k4.tcl 使用的是nix路由算法，nam动态显示使用nix所有的TCP流只经过同一个core交换机，单一路径，有网络瓶颈。之前做实验验证，不使用nix，则ns2会使用默认的静态路由算法，效果同使用nix。

#3、dctcp-dv-fattree-k4.tcl 、 dctcp-nix-fattree-k4.tcl仿真DCTCP。

#4、measure-delay0.awk 测量编号为0的TCP流的端到端时延。执行方法：awk -f measure-delay0.awk tcp-all.tr >outfile  ,结果可输出到outfile文件内。

#5、throughput.pl 记录吞吐量，使用方法见文件内。
