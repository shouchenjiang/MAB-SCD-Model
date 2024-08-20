/**
* Name: MABSCDRNTEST
* Based on the internal empty template. 
* Author: jiang
* Tags: 
*/


model MABSCDRNTEST

global{
	int nb_student <- 5;//Number of students
	int nb_class <-1; 
	float step <- 1#day;  
	
	date starting_date <- date("2023-09-4"); 
	
	date end_date <- date("2023-10-1");
	
	int nb_cycle <- (end_date-current_date)/(60*60*24)+1;
	
	int forget_day <-2;
	
	float con_a <- 0.7;	

	int review_max <- 4;
	
	list st_mastery_all;
	
	
	file my_file <- csv_file("D:/Users/jiang/Gama_Workspace/my_class_BEN/models/GAMA/historical_data_test/data_test1.csv",",");
	matrix my_historical_data_matrix;  
	list my_historical_data; 
	float SD_diff ;  
	float jaccarSimilarity;
	float historical_inequlity;
	
	list nb_item_mastered_all;
	float L0_p;
	float L1_p;
	float L2_p;
	float L3_p;
	float L4_p;
	
	float inequlity <- 0.0 update: standard_deviation(student collect each.nb_item_mastered);
	
	teacher math_teacher;  
	
	classroom_cell st_cell;
	
	predicate learn_new_knowledge <- new_predicate("take new lesson"); 
	predicate review_knowledge <- new_predicate("review learned knowledge");  
	
	predicate choose_item_review1 <- new_predicate("choose unmasted knowledge to review");
	predicate choose_item_review2 <- new_predicate("choose mastered knowledge to review");
	
	predicate review_unmastered_knowledge <- new_predicate("knowledge has learned but unmastered");//代表已经学过的但还未掌握的知识
	predicate review_mastered_knowledge <- new_predicate("knowledge has learned and mastered");//代表已经学过的且已掌握的知识
	
	predicate learn_progress_level <- new_predicate("the level of progress");//代表已经打达到的进阶水平
	
	predicate learn_trajectories <- new_predicate("learn_trajectory");//目前的学习路径
	
	predicate statistic_st <- new_predicate("statistic_info");
	
	string current_item_to_teach <- "current item to teach";
	predicate teach_new_knowledge <- new_predicate("teach new knowledge"); //教师教授新知识
	predicate choose_item_teach <- new_predicate(current_item_to_teach);//代表教师要选择的当前授课内容
	
	
	knowledge_base math_knowledge_base;
	
	init {
		create knowledge_base{
			math_knowledge_base <- self;
		}
		
		create teacher{
			math_teacher <- self;	
		}
		 

		create student number:nb_student;
	
		my_historical_data_matrix <- my_file;
		my_historical_data <- rows_list(my_historical_data_matrix);
		
	}	
	
		
		reflex end_simulation when: (current_date = end_date ){
						
			do pause;
				
		}		
}
	

species knowledge_base{

	int nb_items <- 16; 
	
	list items <- [[0,0.94],[1,0.93],[2,0.85],[3,0.85],[4,0.65],[5,0.93],[6,0.85],
				   [7,0.84],[8,0.65] ,[9,0.55] ,[10,0.63] ,[11,0.55] ,
				   [12,0.55] ,[13,0.65] ,[14,0.58] ,[15,0.53]
				  ];
	
	
	matrix knowledge_items_adjacent <- matrix([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0],
											  [0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0],
											  [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
											  [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
											  [0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0],
											  [0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0],
											  [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
											  [0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0],
											  [0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0]
											  );
	
								  
	

matrix knowledge_reachable_matrix <- matrix(  [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0],
											  [0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0],
											  [0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0],
											  [0,1,1,0,0,0,0,1,1,1,0,0,0,0,0,0],
											  [0,1,1,0,0,0,0,1,1,0,1,0,0,0,0,0],
											  [0,1,1,0,0,0,0,1,1,0,1,1,0,0,0,0],
											  [0,1,1,0,0,0,0,1,1,0,1,0,1,0,0,0],
											  [0,1,1,0,0,0,0,1,1,0,0,0,0,1,0,0],
											  [0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0],
											  [0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1]
											  );
											  	
								  
	
	matrix knowledge_mastered_matrix <- matrix([1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0],
											  [0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0],
											  [0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0],
											  [0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0],
											  [0,1,1,0,0,0,0,1,1,1,0,0,0,0,0,0],
											  [0,1,1,0,0,0,0,1,1,0,1,0,0,0,0,0],
											  [0,1,1,0,0,0,0,1,1,0,1,1,0,0,0,0],
											  [0,1,1,0,0,0,0,1,1,0,1,0,1,0,0,0],
											  [0,1,1,0,0,0,0,1,1,0,0,0,0,1,0,0],
											  [0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0],
											  [0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1]
											  ); 
 


list key_item <-[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
int len_key <- length(key_item);

matrix knowledge_mastered_patten <- 0 as_matrix({len_key,1});						  
													  
	  list learning_progression_level_0 <- nil;
	  list learning_progression_level_1 <- [0,1,5];
	  list learning_progression_level_2 <- [2,3,4,6,7];
	  list learning_progression_level_3 <- [8,10,13,14];
	  list learning_progression_level_4 <- [9,11,12,15];
	 					 
	 list teaching_schedule2 <- [0,1,"#",2,"#",3,5,"#","*","#",4,6,"#","*","#","*","#",
	 							 7,"#",8,"#","*","#",9,"#","*","#","*","#","*","#",
	 							 10,"#",11,"#","*","#",12,"#","*","#","*","#","*","#",
	 							 13,"#",14,"#","*","#",15,"#","*","#","*","#","*","#"
	 							 ];
	 
	 list teaching_sequence2 <- [0,1,2,3,5,4,6,7,8,9,10,11,12,13,14,15];
	 
	 
	 list teaching_schedule <- [0,"#",3,4,"#","*","#",1,2,"#",5,6,"#","*","#","*","#",
	 							 7,"#","*","#",8,"#","*","#",10,"#","*","#","*","#",
	 							 11,"#",12,"#","*","#",9,"#","*","#","*","#","*","#",
	 							 13,"#",14,"#","*","#",15,"#","*","#","*","#","*","#"
	 							 ];
	 list teaching_sequence <- [0,3,4,1,2,5,6,7,8,10,11,12,9,13,14,15];
	
	 list teaching_schedule1 <- [0,"#",3,4,"#","*","#",1,2,"#",5,6,"#","*","#","*","#",
	 							 7,8,"#","*","#",10,"#",11,12,"#",9,"#","*","#","*","#",
	 							 13,"#",14,"#","*","#",15,"#","*","#","*","#","*","#",
	 							 "*","#","*","#","*","#","*","#","*","#","*","#","*","#"
	 							 ];
	 list teaching_sequence1 <- [0,3,4,1,2,5,6,7,8,10,11,12,9,13,14,15];
	 
	 list teaching_schedule3 <- [0,"#",1,2,"#","*","#",3,4,"#",5,6,"#","*","#","*","#",
	 							 7,"#",8,"#","*","#",9,"#","*","#","*","#","*","#",
	 							 10,"#",11,"#",12,"#","*","#","*","#","*","#","*","#",
	 							 13,"#",14,"#",15,"#","*","#","*","#","*","#","*","#"
	 							 ];
	
	 list teaching_sequence3 <- [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
	
	 init{
	 	do get_master_patten; 
	 }
	 
  action get_master_patten{
	int m <- 0;
	loop i_col from:0 to:len_key-1{ 
		//column_at
		loop j_col from:(i_col+1) to:(len_key+m-1){
		  
			list a <- column_at(knowledge_reachable_matrix,i_col);
			list b <- column_at(knowledge_mastered_matrix,j_col);
			matrix c;
			//布尔加运算
			c <- 0 as_matrix({1,len_key}); 
			loop k from:0 to:len_key-1{ 	
				bool k_col <- (bool(a[k]) or bool(b[k]));			
				if(k_col = true){
					c[0,k]<- 1;				
				}else{
					c[0,k] <- 0;				
				}
			}
			
			list c_tmp <- c column_at 0;
			bool add_or_not <- true;
			loop k2 from:0 to:len_key+m-1{
				list c_tmp2 <- column_at(knowledge_mastered_matrix,k2);
				if (c_tmp = c_tmp2){
					add_or_not <- false;					break;
				}
			}
			if(add_or_not){
			
			knowledge_mastered_matrix <- append_horizontally(knowledge_mastered_matrix,c);
	   		m <- m+1;
		}
	}		
}
	
	knowledge_mastered_patten <- append_vertically(knowledge_mastered_patten,transpose(knowledge_mastered_matrix)); 
	
		
	int last_row_id <- knowledge_mastered_patten.rows-1;
		
	 }
	
}

//TEACHER AGENT DEFINITION-BDI
species teacher control: simple_bdi {
		 
	int item_location <- 0; 
	
	list my_teach_schedule <- math_knowledge_base.teaching_schedule1 ;	 //若当前采用教学计划1 
	
	bool class_state <- false;
	
	bool teacher_ready <- false; 
	
	int knowledge_taught <- 0;
	
	list current_knowledge_teaching <- nil;
	
	list count_item_taught <- nil;	
	
	
	bool use_social_architecture <- true;
	
	int i <- 0;

	init{
		 do add_desire(predicate: choose_item_teach,strength:3.0); 
	}
	
		
	perceive target: self { 
		if ( (knowledge_taught/math_knowledge_base.nb_items) < 1){
			ask myself {		
				do add_intention(predicate: teach_new_knowledge, strength:5.0); 
			}
		}
		else{ 
			class_state <- false;  //修改课程状态，学生也不再上课；
			do remove_intention(choose_item_teach,true);
			do remove_intention(teach_new_knowledge,true);
			
		}
			
	}
		
	//fulfilment of the " lecture " intention
	plan teach_knowledge_to_student intention: teach_new_knowledge instantaneous:true{  
		
		
		if (empty(current_knowledge_teaching)){  
			do add_subintention(get_current_intention(),choose_item_teach,true);
			do current_intention_on_hold();
		}else{
			
			if(current_knowledge_teaching[0] = '*'){
				
				class_state <- false;
			}
			if(current_knowledge_teaching[0] != '*'){
			
				class_state <- true;  
				
				count_item_taught <- current_knowledge_teaching where (each !="*"); 
				
				knowledge_taught <- knowledge_taught + length(count_item_taught); 
				
			}
			
			
				current_knowledge_teaching <- nil; 
				
				do remove_intention(teach_new_knowledge,true);
			
		} 
}
	
	//Determine the list of items for this lecture based on the lecture plan and following the knowledge hierarchy and relationships
	plan choose_item_to_student intention: choose_item_teach instantaneous: true{
		
		list item_teach <- nil;
		
		loop item_i over: my_teach_schedule{
			item_location <- item_location + 1;
			if (item_i != "#"){
				add item_i to: item_teach;
			}
			else{
				break;
			}
		}
		
		
		loop times: item_location {
			remove from: my_teach_schedule index:0;  
		}
		
		item_location <- 0;
		current_knowledge_teaching <- item_teach;
				
		do remove_intention(choose_item_teach,true);
		
	}		
}

//Class Grid Definition
grid classroom_cell width: 8 height: 6 neighbors: 4 {
	list<classroom_cell> neighbors2 <- (self neighbors_at 2);
}

//STUDENT AGENT DEFINITION-BDI
species student control: simple_bdi {
	float size <- 2.0;
	rgb st_color;
	
	float Cognitive_competence <- gauss(con_a,(1-con_a)/3) with_precision 2;
	
	float wm <- 0.21;
	
	int st_progression_level <- 0;
	
	matrix st_attribute_state;
	
	int st_mastery_model; 
	
	list st_mastery;
	
	list target_item_review1 <- nil;  
	list target_item_review2 <- nil;  
	
	int nb_item_mastered <- 0;
	
	int revision_frequency <- 0;
	
	list new_item_learn <- nil;
	
	LTM my_LTM;
	
	init{
		//location <- st_cell.location;
		
		st_attribute_state <- init_matrix(math_knowledge_base.nb_items -1);
		
		/*Create their "micro-species":LTM in the host Agent, 
		 * the number of which is 1; i.e. each student has a "long term memory". */
		create LTM{
			my_LTM <- self;  
		}

		do add_desire(predicate:review_knowledge);			
	}
	
//Fuction:Initialising the state of the student's cognitive structure
    matrix init_matrix(int item_n){
    	matrix mt1 <- matrix([[[0,0,0]]]); 
    	 
    	if (item_n)=1{
    		return mt1;
    	}else{
    		loop i from:0 to:(item_n-1){
    			matrix mt2 <- matrix([[[0,0,0]]]);
    			mt1 <- append_horizontally(mt1,mt2);
    		}
    		return mt1;
    	}  		 	
    }	    	
    
	
	int j <- 0;
	
// to store the students' state of knowledge at the end of each cycle of the simulation.
reflex item_state_automodify{ 
	
		int last_row_id <- st_attribute_state.rows -1;
		
		list last_row <- nil;
		last_row <- row_at(st_attribute_state,last_row_id);
		
		matrix mat_temp <- init_matrix(math_knowledge_base.nb_items -1);
		
		loop n from:0 to:(math_knowledge_base.nb_items -1){
			mat_temp[n,0] <- last_row[n];
		}
		
		st_attribute_state <- append_vertically(st_attribute_state,mat_temp);
		//Update the LTM
		ask my_LTM{
			do LTM_state_t_old;
		}						
}


      //Save the simulation result data
	action save_data{
	   
	   if(current_date = end_date){
	   	int last_cycle <- int(time/(60*60*24));
			float r_f <- (revision_frequency/(last_cycle*2)) with_precision 2;
		do level_num();
	    	save [name,st_progression_level,st_mastery_model,nb_item_mastered,st_mastery] to: "D:/Users/jiang/Gama_Workspace/my_class_BEN/models/GAMA/dataresult_RN.csv" format: "csv" header: false rewrite:false;
	   		
	   		save [name,Cognitive_competence,r_f,nb_item_mastered,nb_item_mastered/math_knowledge_base.nb_items,st_progression_level] to: "D:/Users/jiang/Gama_Workspace/my_class_BEN/models/GAMA/dataresult_RN_explo.csv" format: "csv" header: false rewrite:false;
	   		
	   		add st_mastery to: st_mastery_all;
	   		
	   		//jaccarSimilarity <- caluatedjaccardSimilarity(st_mastery_all,my_historical_data);
	   		
	   		   		
	   }
	  }
	   	   

   //Statistics on the proportion of students at each level of progression
	  /*The level of progression is set according to the teaching objectives 
    * of the curriculum. */
	action level_num{
		
		list st_level_all <- student accumulate each.st_progression_level;
		
		list<int> L0_n <- st_level_all where (each = 0);
		list<int> L1_n <- st_level_all where (each = 1);
		list<int> L2_n <- st_level_all where (each = 2);
		list<int> L3_n <- st_level_all where (each = 3); 
		list<int> L4_n <- st_level_all where (each = 4);
		
		L0_p <- length(L0_n) / nb_student;
		L1_p <- length(L1_n) / nb_student;   
		L2_p <- length(L2_n) / nb_student; 
		L3_p <- length(L3_n) / nb_student; 
		L4_p <- length(L4_n) / nb_student; 
	}	
	
/*The number of cognitive attributes that students have mastered by the end of the simulation 
 * and their current level of progression are counted. */

	perceive target: self {	
		do add_intention(predicate:statistic_st);
	}
    
	plan statistic_data intention:statistic_st instantaneous:true{	
		
		list st_level_current <- nil;		
		
		list item_row_temp <- nil;
		
		
		int last_row_id <- st_attribute_state.rows -1;
		
		nb_item_mastered <- 0;
		
		item_row_temp <- row_at(st_attribute_state,last_row_id);
	
		
		loop item_n from:0 to:(math_knowledge_base.nb_items-1){ 
			if(item_row_temp[item_n][1]=1){
				nb_item_mastered <- nb_item_mastered+1;
				add item_n to: st_level_current;
			}	
		}
		
		do st_level_test(st_level_current);
		
		
		st_mastery <- nil;
		loop item_n from:0 to:(math_knowledge_base.nb_items-1){
				int i_m <- int(item_row_temp[item_n][1]);
				add i_m to: st_mastery;
		}
		
		list st_mastery_key <- [];
		loop k_item over:math_knowledge_base.key_item{
			
			add st_mastery[k_item] to: st_mastery_key;
		}
		loop st_m from:0 to:(math_knowledge_base.knowledge_mastered_patten.rows-1){
			if(st_mastery_key = row_at(math_knowledge_base.knowledge_mastered_patten , st_m)){
				st_mastery_model <- st_m;
				break;
			}
		}
		
		
		last_row_id <- st_attribute_state.rows-1;
		
		do save_data;
		
		
		do remove_intention(statistic_st,true);
	}
	
	//current level of progression
	action st_level_test(list st_level){
		
		st_progression_level <- 0;
		
		loop l_item over:st_level{
			if(st_progression_level = 0 and math_knowledge_base.learning_progression_level_1 contains l_item){
				st_progression_level <- 1;
				break;
			}
			}
		loop l_item over:st_level{
			if(st_progression_level = 1 and math_knowledge_base.learning_progression_level_2 contains l_item){
				st_progression_level <- 2;
				break;
			}
			}
		loop l_item over:st_level{
			if(st_progression_level = 2 and math_knowledge_base.learning_progression_level_3 contains l_item){
				st_progression_level <- 3;
				break;
			}	
		}  
		loop l_item over:st_level{
			if(st_progression_level = 3 and math_knowledge_base.learning_progression_level_4 contains l_item){
				st_progression_level <- 4;
				break;
			}	
		}  
		
	}
	
	//Review of acquired knowledge
	perceive target: self when: flip(Cognitive_competence) { 
	
		do add_intention(predicate:review_mastered_knowledge);
	}
	//Reviewing of the knowledge that has been learnt but not yet mastered
	perceive target: self when: flip(Cognitive_competence) { 
		do add_intention(predicate:review_unmastered_knowledge);
	}
	
	//Participate in the teacher's new lesson
	perceive target: self {
		if(math_teacher.class_state = true){  		
					
			do add_intention(predicate: learn_new_knowledge, strength: 5.0); 
			
		}	
	}
	
	
	rule belief: review_unmastered_knowledge new_desire: review_knowledge strength: 3.0;  
	rule belief: review_mastered_knowledge new_desire: review_knowledge strength: 2.0;  	
	
	//Used to implement learn_new_knowledge intent
	plan learn_new_plan intention: learn_new_knowledge instantaneous: true{
		 //get the content of this lesson
		 new_item_learn <- math_teacher.count_item_taught;
		 
		 if(new_item_learn != nil){
		 	//Modify the state of the cognitive attribute based on the content of the lesson	 
		 	do modify_item_learned1(new_item_learn); 
		 	 
		 }
		 new_item_learn <- nil;
		 
		 do remove_intention(learn_new_knowledge,true); 
	}


  action modify_item_learned1(list items_learned)
	{
		
		int last_row_id <- st_attribute_state.rows -1;	
		
		loop i over: items_learned{
			
			int index_i <- int(i);
			
			st_attribute_state[index_i,last_row_id]<-[1,0,0];
			
			bool master_or_not <- flip(master_or_not_check(index_i)); 
			
			float retriew_p ;
			/*Student's update operation on LTM: for newly learnt content, 
			 * insert the mastered concepts into LTM */
			
			if (master_or_not){
				retriew_p <- 1.0;  
				st_attribute_state[index_i,last_row_id]<-[1,1,retriew_p]; //flip(retriew_p)		
			    		
				ask my_LTM{
					do insert_LTM(index_i);
				}				
			}			
		}		
	}
	
	
//Mastery of taught knowledge through revision
  action modify_item_reviewed(list items_learned)
	{
		
		int last_row_id <- st_attribute_state.rows -1;
		
		list last_row <- row_at(st_attribute_state,last_row_id);
		
		loop i over: items_learned{
			int index_i <- int(i);
			
			bool master_or_not <- flip(master_or_not_check2(index_i));
			
			float retriew_p ;		
			
			if (master_or_not){
			 
				retriew_p <- 1.0;  
				
				st_attribute_state[index_i,last_row_id]<-[1,1,retriew_p]; 	
			    
				ask my_LTM{				
					do insert_LTM(index_i);
				}
				
			}
		}
		
	}
	
/*Updating the last row of the knowledge status matrix for the current round after 
 * a certain knowledge in the LTM has been forgotten */
  action modify_item_forgot(int item_forgot){	
		
		int last_row_id <- st_attribute_state.rows -1;
		
		st_attribute_state[item_forgot,last_row_id]<-[1,0,0]; 	
	
	}
		
/*Determine whether the knowledge point has been mastered in the "new lesson" session. */		
float master_or_not_check(int item_learning){ 
	
	float mastered_p;
	
	bool prior_knowledge <- false;
	
	list prior_row_id <- nil;
	
	list prior_col <- math_knowledge_base.knowledge_items_adjacent column_at item_learning;
	loop row_id from: 0 to: math_knowledge_base.nb_items-1 { 
		if (prior_col[row_id] = 1){
			
			add row_id to: prior_row_id;
		}
	}
	
	if (empty(prior_row_id)){
		prior_knowledge <- true;
	}else{
		
		loop master_test over:prior_row_id{
			int l_row_id <- st_attribute_state.rows-1; 
			if(st_attribute_state[int(master_test),l_row_id][1]=1){
				prior_knowledge <- true;
			}else{
				prior_knowledge <- false;
				break;
			}
		}
	}
	
	if (prior_knowledge){
		
		mastered_p  <- (Cognitive_competence + math_knowledge_base.items[item_learning][1])-Cognitive_competence * math_knowledge_base.items[item_learning][1];
	}
	else 
	{
		mastered_p <- 0.0;
	}
	
	return mastered_p;
}

//Determine whether the point was mastered in the "Review of Unmastered Knowledge" session.		
float master_or_not_check2(int item_learning){ 
	
	float mastered_p;
	
	
	bool prior_knowledge <- false;
	
	list prior_row_id <- nil;
	
	list prior_col <- math_knowledge_base.knowledge_items_adjacent column_at item_learning;
	loop row_id from: 0 to: math_knowledge_base.nb_items-1 { 
		if (prior_col[row_id] = 1){
			//
			add row_id to: prior_row_id;
		}
	}
	//情况1：若row_id 为空，则表示该知识点没有上层知识；
	if (empty(prior_row_id)){
		prior_knowledge <- true;
	}else{
		
		loop master_test over:prior_row_id{
			int l_row_id <- st_attribute_state.rows-1; 
			if(st_attribute_state[int(master_test),l_row_id][1]=1){
				prior_knowledge <- true;
			}else{
				prior_knowledge <- false;
				break;
			}
		}
	}
	
	if (prior_knowledge){
		
		mastered_p  <- (Cognitive_competence + math_knowledge_base.items[item_learning][1]*1.05)-Cognitive_competence * math_knowledge_base.items[item_learning][1]*1.05;
	}
	else 
	{
		mastered_p <- 0.0;
	}
	
	return mastered_p;
}
		
	//Reviewing Unacquired Knowledge
	plan review_plan_unmastered intention:review_unmastered_knowledge instantaneous:true{ 
		 //If you haven't decided what you want to review, add a sub-intent of "Select Review Content"
		 if(empty(target_item_review1)){
		 	do add_subintention(get_current_intention(),choose_item_review1,true);  
		 	do current_intention_on_hold();
		 }else{    //Modify the status of the cognitive attribute to be reviewed.
		 	
		 	int review_n <- 0; 
		 	list item_review_today1 <- [];
		 	if (length(target_item_review1)>= review_max){
		 		review_n <- rnd(1,review_max);  
		 		}	
		 	else{
		 		review_n <- rnd(1,length(target_item_review1)); 
		 	}
		 	loop i from:0 to: (review_n-1){ 
		 			add target_item_review1[i] to:item_review_today1;
		 		}	
		 			 	
		 	do modify_item_reviewed(item_review_today1);
		 	
		 	target_item_review1 <- nil; 
		 			 	
		 	do remove_intention(review_unmastered_knowledge,true);
		 	
		    revision_frequency <- revision_frequency+1;
		 }
		 
	}		  
	
	//Select review content from all learned but not mastered knowledge.
	plan choose_current_item_review1 intention:choose_item_review1 instantaneous:true{
		
		list unmastered_knowledge <- nil;
		
		int last_row_id <- st_attribute_state.rows -1;
		
		list last_row <- nil;
		last_row <- row_at(st_attribute_state,last_row_id);
		
		loop r_id from:0 to: (math_knowledge_base.nb_items-1){
			if(last_row[r_id][0]=1 and last_row[r_id][1]=0){
				add r_id to: unmastered_knowledge;
			}
		} 
		
	 	list t_sequnce2 <- [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
	 	
	 	list t_sequnce <- [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
	
		loop t_item over:math_knowledge_base.teaching_sequence1{
			if(!(unmastered_knowledge contains t_item)){ 
				remove t_item from:t_sequnce;  
			}
		  }
		 
		 unmastered_knowledge <- t_sequnce;			
		
		if (empty(unmastered_knowledge)){ 	
			do remove_intention(review_unmastered_knowledge,true);
		}else{
			target_item_review1 <- unmastered_knowledge; 		
		}
		do remove_intention(choose_item_review1,true);				
	}
	
//Review the knowledge that has not been mastered.
	plan review_plan_mastered intention:review_mastered_knowledge instantaneous:true{ 
		
		 //如果还没有确定要复习的知识点
		 if(empty(target_item_review2)){
		 	do add_subintention(get_current_intention(),choose_item_review2,true); 
		 	do current_intention_on_hold();
		 }else{  
		 	loop r_i over: target_item_review2{
		 		ask my_LTM{
		 		/// calls the LTM method according to the content to be reviewed.
		 		do LTM_revise(int(r_i));
		 	}
		 	}
		 	
		 	target_item_review2 <- nil; 
		 	
		 	do remove_intention(review_mastered_knowledge,true);
		 	
		    revision_frequency <- revision_frequency+1;
		 }
		  
	}
	
	//Select revision from all that has been learnt and mastered
	plan choose_current_item_review2 intention:choose_item_review2 instantaneous:true{
		
		ask my_LTM{
			do sort_by_mscore;
		}
		list mastered_knowledge <- my_LTM.vertices_orderby_score;	
		
		if (length(mastered_knowledge)=0){ 		
			do remove_intention(review_mastered_knowledge,true);
		}else{
		 	int review_n <- 0; 
		 	list item_review_today2 <- nil;
		 	if (length(mastered_knowledge)>= review_max){
		 		review_n <- rnd(1,review_max);  
		 		}	
		 	else{
		 		review_n <- rnd(1,length(mastered_knowledge)); 
		 	}
		 	loop i from:0 to: (review_n-1){ 
		 			add mastered_knowledge[i] to:target_item_review2;
		 		}	

		}
		do remove_intention(choose_item_review2,true);
	}
	

	aspect base{
		if(st_progression_level = 1){
			st_color <- #blue;
		}
		if(st_progression_level = 2){
			st_color <- #green;
		}
		if(st_progression_level = 3){
			st_color <- #yellow;
		}
		if(st_progression_level = 4){
			st_color <- #red;
		}
		if(st_progression_level = 0){
			st_color <- #pink;
		}
		draw circle(size) color: st_color border: #black;
	}
	
//Long-term memory Agent Definition
 species LTM{
 	
 	list vertices_orderby_score <- nil;
 	
 	matrix LTM_edge <- 0 as_matrix({math_knowledge_base.nb_items+1,math_knowledge_base.nb_items+1});  
 	
 	list LTM_vertices <- [[0.0,0,0,0,0],[0.0,0,0,0,1],[0.0,0,0,0,2],[0.0,0,0,0,3],[0.0,0,0,0,4],[0.0,0,0,0,5],[0.0,0,0,0,6],[0.0,0,0,0,7],[0.0,0,0,0,8],[0.0,0,0,0,9],[0.0,0,0,0,10],
 						  [0.0,0,0,0,11],[0.0,0,0,0,12],[0.0,0,0,0,13],[0.0,0,0,0,14],[0.0,0,0,0,15],[0.0,0,0,1,16]];
 						 
 	
 	list LTM_edges_t1<-[];
 	list LTM_edges_t2<-[];
 	
 	int n <- math_knowledge_base.nb_items;
 	
 	float cic <- 0.1; 
 	float w_T <- 0.1; 
 	float s_AT <- 1.0;
 	int D <- 5;  
 	float cil <- 0.001;  	
 	float r_dec <-0.1;  	
 	float e_r_dec <- exp(r_dec);
 	
 //Initialise the current simulation with the state of the previous round of edges 	
 	action LTM_state_t_old{	
 		
 		LTM_edges_t1 <- LTM_edges_t2;
 			
 		float m_score_t;
 		
 		loop i_m from:0 to:(length(LTM_vertices)-1){
 			if(LTM_vertices[i_m][3]=1){
 				m_score_t <- motive_socre(i_m);
 				LTM_vertices[i_m][0] <- m_score_t;  
 				LTM_vertices[i_m][2] <- int(LTM_vertices[i_m][2])+1; 
 			} 									
 	}
 		
 		do LTM_weaken;
 		
 		do delete_from_LTM;	
 	
 }	
 	
 	
    /*When a cognitive attribute has not been used for more than a forget_day, 
     * the level of mastery of that knowledge will decay. */	
 	action LTM_weaken{
 		
 		list x_weaken <- nil;
 		
 		loop i_w from:0 to:(length(LTM_vertices)-2){
 			
 			if(int(LTM_vertices[i_w][3])=1 and int(LTM_vertices[i_w][2])> forget_day){
 				//add i_w to: x_weaken;
 				do action_weaken(i_w);
 			}	
 		}	
 				
 	}
	
 	
 	//Equation-7
 	action action_weaken(int x){
 		
 	if(length(LTM_edges_t2)!=0){
 		loop z_w from: 0 to: length(LTM_edges_t2)-1{  			
 			
 			if(int(LTM_edges_t2[z_w][0])=x){
 				int y_weaken1 <- int(LTM_edges_t2[z_w][1]);
 				
 			 float z_1<- (len_t1(x,y_weaken1) * e_r_dec) with_precision 2;
 			 
 			 LTM_edges_t2[z_w] <- [x,y_weaken1,z_1]; 
 
 			}
 			
 			if(int(LTM_edges_t2[z_w][1])=x){
 				int y_weaken2 <- int(LTM_edges_t2[z_w][0]);
 			float z_2 <- (len_t1(y_weaken2,x)* e_r_dec) with_precision 2;
 			
 			 LTM_edges_t2[z_w] <- [y_weaken2,x,z_2]; 
 			}
 		  }
 		}
 	
 	}
 	
 	/*Check the length of the confusion interval for all edges in LTM_edges_t2, and if the length is 2, remove this edge, i.e., this one, 
 	 * and the vertex to which this edge "points". */
 	action delete_from_LTM{		
 		
 		list d_item <- nil ; 
 		loop edge_d over:LTM_edges_t2{
 			
 			if(float(edge_d[2]) >= 2.0){  
 				add edge_d[1] to:d_item ; 
 				
 			}	
 		}
 		
 		
 		if(!empty(d_item)){
 			loop i_v over:d_item{
 				
 					list visited <- nil;
 					do delete_v(int(i_v),visited);
 					
 		   			do delete_v2(int(i_v)); 	    			 				
 			}
 		}
 		
		int last_row_id <- st_attribute_state.rows-1;
		
 	}
 
// depth-first traversal removes nodes and edges behind a nod
 action delete_v(int currentVertex,list v_Vertices){
 	if (!(v_Vertices contains currentVertex)) {
    add currentVertex to: v_Vertices;
  // Recursive call for all neighbors
    list ver_adj <- v_adj(currentVertex);
    
    // Remove the current vertex and its outgoing edges by updating the adjacency matrix
    //graph.adjacencyMatrix[currentIndex, all] <- false;
    loop j1 from:0 to:n{ 
			if(LTM_edge[j1,currentVertex]=1){
				LTM_edge[j1,currentVertex] <- 0;
			do remove_index(currentVertex,j1,LTM_edges_t2); 
				  
			}
			LTM_vertices[currentVertex]<-[0.0,0,0,0,currentVertex];
			
			ask host{
           		do modify_item_forgot(currentVertex);
            }
		}		
     
    loop v_j over: ver_adj{
     if(v_j != nil){
        do delete_v(int(v_j),v_Vertices);
        
      }
    }

  }
 	
 }
	 
   list v_adj(int v){
	list v_a <- nil;
	loop i from:0 to:n-1{ 
		if(LTM_edge[i,v]=1){
			add i to: v_a;
		}
	}
	return v_a;
}
action delete_v2(int v_self){
	loop j2 from:0 to:n{ 
			if(LTM_edge[v_self,j2]=1){
				LTM_edge[v_self,j2] <- 0;
			
			do remove_index(j2,v_self,LTM_edges_t2); 	  
			}
		}
		
		LTM_vertices[v_self]<-[0.0,0,0,0,v_self];
		ask host{
           do modify_item_forgot(v_self);
        }
}	
	
//remove edge information from x to y from the edge list	
action remove_index(int x,int y,list edges){  
	int edg_index;
	loop p from:0 to: length(LTM_edges_t2)-1{
		if(LTM_edges_t2[p][0]=x and LTM_edges_t2[p][1]=y){
			edg_index <- p;
		}
	}
	remove index: edg_index from: LTM_edges_t2; 	
}
	

 // sort all mastered points by motivation score from smallest to largest
	 action sort_by_mscore{
 			vertices_orderby_score <-nil;
 			list v_order_tmp <-reverse(LTM_vertices sort_by (each[0]));
 			list v_order_tmp2;
 			
 			loop s_i from:0 to:n-1{
 				if (v_order_tmp[s_i][3]=1 and v_order_tmp[s_i][0]!=math_knowledge_base.nb_items){
 					add v_order_tmp[s_i] to:v_order_tmp2;
 				}
 			}
 			
 	       if(!empty(v_order_tmp2)){  
 			loop i_m from:0 to:(length(v_order_tmp2)-1){
 				
 				if(v_order_tmp2[i_m][4]!= n and float(v_order_tmp2[i_m][0]) >= s_AT){
 					add v_order_tmp2[i_m][4] to: vertices_orderby_score;
 				}
 			}
 			
 			}
 			
 	
 		}
 	
 	//add vertices and edges to LTM when certain knowledge points have been mastered in this round of simulation
 	action insert_LTM(int item_mastered){
 		
 		bool test_first <- true; 
       
		list prior_row_id;
		list prior_col <- math_knowledge_base.knowledge_items_adjacent column_at item_mastered;
		loop row_id from: 0 to: math_knowledge_base.nb_items-1 { //注意下标范围
		if (prior_col[row_id] = 1){
		
		add row_id to: prior_row_id;
		}
	}
		
		if (empty(prior_row_id)){
		test_first <- true;
		}else{
			test_first <- false;
		}

 	
 		if (test_first){
 	
 			LTM_vertices[item_mastered][3] <- 1; 
 			
 			LTM_edge[item_mastered,n]<- 1;  
 		    		   
 		    
 		    add [n,item_mastered,(len_confusion_t2(n,item_mastered))+wm] to: LTM_edges_t2; 
 		    
 		   
 		}else{			
 			LTM_vertices[item_mastered][3]<- 1;
 			
 			list item_id_temp <- nil;
 			loop i from:0 to:(n-1){
 				
 				if(math_knowledge_base.knowledge_items_adjacent[item_mastered,i]=1){
 					add i to:item_id_temp;
 				} 				
 			}
 			
 			loop i_insert over:item_id_temp{
 				
 				LTM_edge[item_mastered,int(i_insert)] <- 1;
 				float m_i <- len_confusion_t2(int(i_insert),item_mastered);
 				
 				add [int(i_insert),item_mastered,(m_i+wm)] to: LTM_edges_t2;	
 			}
 			
 		}
 	
 	}
 	
 /*// Modify the length of the confusion interval of the edge 
  * where the knowledge point is located when the student reviews 
  the knowledge in the LTM; */ 		
 	action LTM_revise(int v_r){
 		
 		LTM_vertices[v_r][1] <-1;			
 		LTM_vertices[v_r][2] <-0; 
 				
 			if(length(LTM_edges_t2)>1){
 			loop e_r from:0 to: length(LTM_edges_t2)-1{ 
 				if(LTM_edges_t2[e_r][0]= v_r){  
 				   
 					int v_y <- int(LTM_edges_t2[e_r][1]); 
 					
 		           if(min_con_len(v_r,v_y)){
 		           
 		           LTM_vertices[v_y][1] <-1;			
 				   LTM_vertices[v_y][2] <-0; 
 		            
 		           
 					float l_r;
 					l_r <- len_confusion_t2(v_r,v_y)with_precision 2;  
 					LTM_edges_t2[e_r]<- [int(v_r),v_y,l_r]; 
 					
 					loop e_r2 from:0 to: length(LTM_edges_t2)-1{
 						if(LTM_edges_t2[e_r2][0]= v_y){  //以v_y为出点的边
 							
 							int v_k <- int(LTM_edges_t2[e_r2][1]);							
 							
 							LTM_edges_t2[e_r2]<-[v_y,v_k,LTM_revise2(v_y,v_k)with_precision 2];
 							
 							}
 								
 						if(LTM_edges_t2[e_r2][1]= v_y and LTM_edges_t2[e_r2][0]!=v_r){  //以v_y为入点的边
 							
 							int v_k2 <- int(LTM_edges_t2[e_r2][0]);
 							
 							LTM_edges_t2[e_r2]<-[v_k2,v_y,LTM_revise2(v_k2,v_y)with_precision 2];
 														
 							}
 					}
 					
 					LTM_vertices[v_r][0] <- 0;	
 					
 					} 
 				} 
 				
 				if(LTM_edges_t2[e_r][1]=v_r){
 					int v_x <- int(LTM_edges_t2[e_r][0]);
 		   			
 		           if(min_con_len(v_x,v_r)){
 					
 		           LTM_vertices[v_x][1] <-1;	
 				   LTM_vertices[v_x][2] <-0; 
 					
 					float l_r2 <- len_confusion_t2(v_x,v_r)with_precision 2;
 					
 					LTM_edges_t2[e_r]<-[v_x,v_r,l_r2];
 					
 					loop e_r3 from:0 to: length(LTM_edges_t2)-1{
 						if(LTM_edges_t2[e_r3][1]= v_x){
 							
 							int v_i <- int(LTM_edges_t2[e_r3][0]);
 							
 							LTM_edges_t2[e_r3]<-[v_i,v_x,LTM_revise2(v_i,v_x)with_precision 2];
 							
 						}
 						if(LTM_edges_t2[e_r3][0]= v_x and LTM_edges_t2[e_r3][1]!=v_r){
 							
 							int v_i2 <- int(LTM_edges_t2[e_r3][1]);
 							
 							LTM_edges_t2[e_r3]<-[v_x,v_i2,LTM_revise2(v_x,v_i2) with_precision 2 ];
 							
 						}
 					}
 					
 					LTM_vertices[v_x][0] <- 0;	
 					
 				}	
 			  }
 			}
 			}
 		
 					
 		LTM_vertices[int(v_r)][1] <-0;	
 	
 	}
 	
 
bool min_con_len(int v_x, int v_y){
	float con_test <- 0.0;
	
	loop min_i from: 0 to: length(LTM_edges_t2)-1{
		if (LTM_edges_t2[min_i][0]=v_x and LTM_edges_t2[min_i][1]=v_y){
			con_test <- float(LTM_edges_t2[min_i][2]);
			break;
		}
	}
	if con_test < 0.21{ 
		return false;
	}else{	
		return true;
	}	
}
 //Equation 4/5/6	
 	float LTM_revise2(int z, int k){
 		float len_conf2;
 		
 		float mf <- f(z)*(motive_socre(z)-s_AT)+f(k)*((motive_socre(k)-s_AT));
 		
 		int dx <- 2;
 		float sf <- 1-(2/D);
 		
 		
 		len_conf2 <- len_t1(z,k)-sf*mf*cil;	
 			
 		
 		return len_conf2 with_precision 2;		
 	}
 	
 //Equation 2
 	float len_confusion_t2(int x,int y){
 		float len_xy <- 0.0;
 		float m_x <- motive_socre(x);
 		
 		float m_y <- motive_socre(y);
 		
 		int f_x <- f(x);
 		
 		int f_y <- f(y);
 		
 		float len_xy_pre <- len_t1(x,y)/2;  
 		
 	
 		len_xy <- (cic*(f_x * m_x + f_y * m_y)*w_T +len_xy_pre)/(cic*(f_x * m_x + f_y * m_y)+1) ;
 		
 			return len_xy*2 with_precision 2;
 		

 	}
 	
  	//Equation 1	
	float motive_socre(int x){
		
		float sum_len <- 0.0;
		loop s over: LTM_edges_t2 {
			if(s[0]=x or s[1]= x){
				if(s[2]!=0.0){			
					float i <- float(s[2]);
					sum_len <- sum_len + 1/i;
				}
				
			}	
		}
		return sum_len with_precision 2;
	}
	//Equation 3
	int f (int x){
		if(int(LTM_vertices[x][1])= 1){
			return 1;
		}else{
			return 0;
		}		
	}
	//Query the length of the confusion interval of the last moment of the edge xy
	float len_t1(int x,int y){
		float l2 <- 0.0;
		if(empty(LTM_edges_t1)){
			return 0.0;
		}else{
		loop d over: LTM_edges_t1{
			if(d[0]= x and d[1]=y){
				l2 <- float(d[2]);
				break;	
			}
		}
		}
		return l2 with_precision 2;
	}

}	
}


experiment math_class_exp type: gui {
	
	output {
	
	   
	 display chart{  
	 	
	 	chart "Item_number" type: series{
	 		datalist legend: student accumulate each.name value: student accumulate each.nb_item_mastered color: student accumulate each.st_color;
	 		
	 	}
	 }
	
	  
	 display "st_progression_level_chart" {
	    chart "progression_level" type: histogram {
			 
			datalist (distribution_of(student collect each.st_progression_level,5,0,5) at "legend") 
		    	value:(distribution_of(student collect each.st_progression_level,5,0,5) at "values");
		    		
	    }
	}
	
	//柱状图2，显示学生的进阶水平比例：st_Attribute_mastery_model
	/*  
	 display "st_mastery_model_chart" {
	    chart "mastery_model" type: histogram {
			int model_nb <-  math_knowledge_base.knowledge_mastered_patten.rows;
			datalist (distribution_of(student collect each.st_mastery_model,model_nb,0,model_nb) at "legend") 
		    	value:(distribution_of(student collect each.st_mastery_model,model_nb,0,model_nb) at "values");
		    		
	    }
	}
	*/
	/* 
	display "st_item_mastered" {
	   		chart "item_mastered_number" type: series {
				datalist student collect (each.name) value:  student collect (each.nb_item_mastered) color: student collect (each.st_color) ;
		    }
		}
	*/
	
	  
	display mastery_level  {																		 
    chart "Mastery_patten & Progression_level" type: xy {							
        data 'Mastery_patten/Progression_level' value: {first(student).st_mastery_model, first(student).st_progression_level} color: #black ;		
    }
  }
 
    

	}
}


experiment explo_local type:batch repeat:10 parallel:0 until:cycle= (nb_cycle+1){
   //[parameter to explore]
   //[exploration method]
   reflex save_data{
   			
   }
}










