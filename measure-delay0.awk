#�o�O���q�Ĥ@��TCP��Ƭy�ʥ]���I����I������ɶ���awk�{��

BEGIN {
#�{����l�ơA�]�w�@�ܼƥH�O���ثe�̰��B�z�ʥ]��ID�C
     highest_packet_id = 0;
}
{
   action = $1;
   time = $2;
   from = $3;
   to = $4;
   type = $5;
   pktsize = $6;
   flow_id = $8;
   src = $9;
   dst = $10;
   seq_no = $11;
   packet_id = $12;

#�O���ثe�̰���packet ID
   if ( packet_id > highest_packet_id )
	 highest_packet_id = packet_id;

#�O���ʥ]���ǰe�ɶ�
   if ( start_time[packet_id] == 0)  
	start_time[packet_id] = time;

#�O���Ĥ@��TCP(flow_id=0)�������ɶ�
   if ( flow_id == 0 && action != "d" && type=="tcp") {
      if ( action == "r" ) {
         end_time[packet_id] = time;
      }
   } else {
#�⤣�Oflow_id=0���ʥ]�Ϊ̬Oflow_id=0�����ʥ]�Qdrop���ɶ��]��-1
      end_time[packet_id] = -1;
   }
}							  
END {
	sum_delay=0;
	no_sum=0;
#���ƦC����Ū������A�}�l�p�⦳�īʥ]�����I����I����ɶ� 
    for ( packet_id = 0; packet_id <= highest_packet_id; packet_id++ ) {
       start = start_time[packet_id];
       end = end_time[packet_id];
       packet_duration = end - start;

#�u�Ⱶ���ɶ��j��ǰe�ɶ����O���C�X��
       if ( start < end ) {
       	  #printf("%f %f\n", start, packet_duration);
       	  sum_delay+=packet_duration;
       	  no_sum+=1;
       }
   }

#�D�X�����ʥ]���I����I���𪺮ɶ�   
   printf("average delay: %f sec\n", sum_delay/no_sum);
}
