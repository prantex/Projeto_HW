module uc(
 input logic CLK,//ok
 input logic RESET,//ok
 input logic Igual,
 input logic [31:0] IR31_0,//ok
 input logic [4:0] IR11_7, IR19_15, IR24_20,//ok
 input logic [6:0] IR6_0,//ok
 output logic ALU_SRCA, RESET_WIRE, PC_WRITE, IR_WIRE, MEM32_WIRE, LOAD_A, LOAD_B, BANCO_WIRE, LOAD_ALU_OUT, LOAD_MDR, MEM_TO_REG, WRITE_REG, DMEM_RW,
 output logic [2:0] ALU_SELECTOR,
  output logic [6:0] ESTADO_ATUAL,
 output logic [1:0] ALU_SRCB,
 output logic [15:0] SAIDA_ESTADO,
output logic[31:25]FUNCT7
 );
 enum logic [15:0]{
  RESET_ESTADO, //0
  BUSCA, //1
  SOMA, //2
  DECODE, //3
  R, //4
  ADDI, //5
  SD1, //6 
  SD2,
  LD1, //7
  LD2,
  LD3,
  BEQ, BEQ2, //8,9
  BNE, BNE2, // 10,11
  LUI //12
 }ESTADO, PROX_ESTADO;
 
 always_ff@(posedge CLK, posedge RESET)
 begin
  if(RESET)
  begin
   ESTADO<=RESET_ESTADO;
  end
  else 
  begin
   ESTADO<=PROX_ESTADO;
  end
 end
 
 assign ESTADO_ATUAL = ESTADO;
 assign FUNCT7 = IR31_0[31:25];
 always_comb 
 case(ESTADO)
  RESET_ESTADO:
  begin
   SAIDA_ESTADO = 0;
   PC_WRITE = 0;
   RESET_WIRE = 1;
   ALU_SRCA = 0;
   ALU_SRCB = 0;
   ALU_SELECTOR = 0;
   LOAD_ALU_OUT = 0; //FALTA DECLARAR NA UP
   DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
   MEM32_WIRE = 0;
   IR_WIRE = 0;
   LOAD_A = 0;
   LOAD_B = 0;
   LOAD_MDR = 0;
   BANCO_WIRE = 0;
   MEM_TO_REG = 0;
   PROX_ESTADO = BUSCA;
  end
  BUSCA:
  begin
   SAIDA_ESTADO = 1;
   PC_WRITE = 0;
   RESET_WIRE = 0;
   ALU_SRCA = 0;
   ALU_SRCB = 0;
   ALU_SELECTOR = 0;
   LOAD_ALU_OUT = 0; //FALTA DECLARAR NA UC
   DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
   MEM32_WIRE = 0;
   IR_WIRE = 1;
   LOAD_A = 0;
   LOAD_B = 0;
   LOAD_MDR = 0;
   BANCO_WIRE =1 ;
   MEM_TO_REG=0;
   PROX_ESTADO = SOMA;
  end
  SOMA:
  begin
   SAIDA_ESTADO = 2;
   PC_WRITE = 1;
   RESET_WIRE = 0;
   ALU_SRCA = 0;
   ALU_SRCB = 1;
   ALU_SELECTOR = 1;
   LOAD_ALU_OUT = 0; //TAVA 1
   DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
   MEM32_WIRE = 0;
   IR_WIRE = 0;
   LOAD_A = 0;
   LOAD_B = 0;
   LOAD_MDR = 0;
   BANCO_WIRE = 0 ;
   MEM_TO_REG = 0;
   PROX_ESTADO = DECODE;
  end
  DECODE:
  begin
   IR_WIRE = 0;
   PC_WRITE = 0;
   SAIDA_ESTADO = 3;
   case(IR6_0)//LER OPCODE
    51://ADD,SUB LEMBRAR QUE O OPCODE ESTA MODIFICADO
     begin
      PROX_ESTADO = R;
     end
    19://ADDI
     begin
      PROX_ESTADO = ADDI;
     end
    3://LD
     begin
      PROX_ESTADO = LD1;
     end
    35://SD
     begin
      PROX_ESTADO = SD1;
     end 
    99://BEQ1
     begin
      PROX_ESTADO = BEQ;
     end
    103://BNE
     begin
      PROX_ESTADO = BNE;
     end
    55://LUI
     begin
      PROX_ESTADO = LUI;
     end
   endcase
  end
  R:
   begin
    PROX_ESTADO = BUSCA;
    case(FUNCT7) //CONFIRMAR QUE A FUNCT7 TA NESSE INTERVALO E VE SE PODE DEIXAR ASSIM
     0: //ADD
      begin
       SAIDA_ESTADO = 4;
       PC_WRITE = 0;
       RESET_WIRE = 0;
       ALU_SRCA = 1; //SELECIONA O REG_A_MUX
       ALU_SRCB = 0; //SELECIONA O REG_B_MUX
       ALU_SELECTOR = 1; //SOMA 001
       LOAD_ALU_OUT = 1; //FALTA DECLARAR NA UC
       DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
       MEM32_WIRE = 0;
       IR_WIRE = 0;
       LOAD_A = 1;
       LOAD_B = 1; 
       LOAD_MDR = 0;
       BANCO_WIRE = 0;
       MEM_TO_REG = 0;
       PROX_ESTADO = BUSCA;
      end
     32: //SUB
      begin
       SAIDA_ESTADO = 5;
       PC_WRITE = 0;
       RESET_WIRE = 0;
       ALU_SRCA = 1; //SELECIONA O REG_A_MUX
       ALU_SRCB = 0; //SELECIONA O REG_B_MUX
       ALU_SELECTOR = 2; //SUB 010
       LOAD_ALU_OUT = 1; //FALTA DECLARAR NA UC
       DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
       MEM32_WIRE = 0;
       IR_WIRE = 0;
       LOAD_A = 1;
       LOAD_B = 1; 
       LOAD_MDR = 0;
       BANCO_WIRE = 0;
       MEM_TO_REG = 0;
       PROX_ESTADO = BUSCA;
      end
     default: SAIDA_ESTADO[6:0] =99;
    endcase
   end
  ADDI:
   begin
    SAIDA_ESTADO = 6;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 1;
    ALU_SRCB = 2;
    ALU_SELECTOR = 1;
    LOAD_ALU_OUT = 1;
    DMEM_RW =0;
    MEM32_WIRE = 0;
    IR_WIRE = 0;
    LOAD_A = 1;
    LOAD_B = 1;
    LOAD_MDR = 0;
    BANCO_WIRE = 0;
    MEM_TO_REG=0;
    PROX_ESTADO = BUSCA;
   end
  SD1:
   begin
    SAIDA_ESTADO = 7;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 1;
    ALU_SRCB = 2;
    ALU_SELECTOR = 1;
    LOAD_ALU_OUT = 1; //FALTA DECLARAR NA UC
    DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
    MEM32_WIRE = 0;//ERA 1
    IR_WIRE = 0;//ERA 1
    LOAD_A = 1;
    LOAD_B = 1;
    LOAD_MDR = 0;
    BANCO_WIRE = 0;
    MEM_TO_REG = 0;
    PROX_ESTADO = SD2;
   end
         SD2:
   begin
    SAIDA_ESTADO = 8;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 1;//?
    ALU_SRCB = 2;//?
    ALU_SELECTOR = 1;//?
    LOAD_ALU_OUT = 1; //?
    DMEM_RW = 1; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
    MEM32_WIRE = 0;//era 1
    IR_WIRE = 0;//era 0
    IR_WIRE = 0;
    LOAD_A = 0;//0
    LOAD_B = 0;//0
    LOAD_MDR = 0;
    BANCO_WIRE = 0;
    MEM_TO_REG = 0;
    PROX_ESTADO = BUSCA;
   end

  BEQ:
   begin
    SAIDA_ESTADO = 9;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 1;
    ALU_SRCB = 0;
    ALU_SELECTOR = 1;
    LOAD_ALU_OUT = 1; //FALTA DECLARAR NA UC
    DMEM_RW = 1; //0 => 
    MEM32_WIRE = 0;
    IR_WIRE = 1;
    LOAD_A = 1;
    LOAD_B = 1; 
    LOAD_MDR = 0;
    //BANCO_WIRE = ;
    //MEM_TO_REG=;
    PROX_ESTADO = BEQ2;
   end
  BEQ2:
   begin
    SAIDA_ESTADO = 10;
    if(Igual == 1)
    begin
     PC_WRITE = 0;
     RESET_WIRE = 0;
     ALU_SRCA = 0;
     ALU_SRCB = 3;
     ALU_SELECTOR = 001;//1
     LOAD_ALU_OUT = 1; //FALTA DECLARAR NA UC
     DMEM_RW = 1; //0 => 
     MEM32_WIRE = 0;
     IR_WIRE = 1;
     LOAD_A = 1;
     LOAD_B = 1;
     LOAD_MDR = 0;
     //BANCO_WIRE = ;
     //MEM_TO_REG=;
     PROX_ESTADO = BUSCA;
    end
   end
  BNE:
   begin
    SAIDA_ESTADO = 11;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 1;
    ALU_SRCB = 0;
    ALU_SELECTOR = 001;//1
    LOAD_ALU_OUT = 1; //FALTA DECLARAR NA UC
    DMEM_RW = 1; //0 => 
    MEM32_WIRE = 0;
    IR_WIRE = 1;
    LOAD_A = 1;
    LOAD_B = 1;
    LOAD_MDR = 0;
    //BANCO_WIRE = ;
    //MEM_TO_REG=;
    PROX_ESTADO = BEQ2;
   end
  BNE2:
   begin
    SAIDA_ESTADO = 12;
    if(Igual != 1)
    begin
     PC_WRITE = 0;
     RESET_WIRE = 0;
     ALU_SRCA = 0;
     ALU_SRCB = 3;
     ALU_SELECTOR = 001;//1
     MEM32_WIRE = 0;
     IR_WIRE = 1;
     LOAD_A = 1;
     LOAD_B = 1;
     LOAD_MDR = 0;
     //BANCO_WIRE = ;
     //MEM_TO_REG=;
     PROX_ESTADO = BUSCA;
    end
   end

  LD1:
   begin
    SAIDA_ESTADO = 13;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 1;
    ALU_SRCB = 2;
    ALU_SELECTOR = 1;
    LOAD_ALU_OUT = 1;
    DMEM_RW = 0;
    MEM32_WIRE = 0;//ERA1
    IR_WIRE = 0;
    LOAD_A = 1;
    LOAD_B = 1;
    LOAD_MDR = 0;
    BANCO_WIRE = 0;
    MEM_TO_REG = 0;
    PROX_ESTADO = LD2;
   end
  
  LD2:
   begin
    SAIDA_ESTADO = 14;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 1;//? era 0
    ALU_SRCB = 2;//?
    ALU_SELECTOR = 1;//?
    LOAD_ALU_OUT = 1; //?
    DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
    MEM32_WIRE = 0;//era1
    IR_WIRE =0 ;
    LOAD_A = 0;
    LOAD_B = 0;
    LOAD_MDR = 1;
    BANCO_WIRE = 0;
    MEM_TO_REG = 1;
    PROX_ESTADO = BUSCA;
   end
  
 /* LD3:
   begin
    SAIDA_ESTADO = 15;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 1;
    ALU_SRCB = 2;
    ALU_SELECTOR = 1;
    LOAD_ALU_OUT = 1; //FALTA DECLARAR NA UC
    DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
    MEM32_WIRE = 1;
    IR_WIRE = ;
    LOAD_A = 1;
    LOAD_B = 1;
    LOAD_MDR = 1;
    MEM_TO_REG = 1;
    WRITE_REG = 1;
    BANCO_WIRE = ;
    PROX_ESTADO = BUSCA;
   end
*/
  LUI:
   begin
    SAIDA_ESTADO = 16;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 2;
    ALU_SRCB = 2;
    ALU_SELECTOR = 1;
    LOAD_ALU_OUT = 1; //FALTA DECLARAR NA UC
    DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
    MEM32_WIRE = 0;
    IR_WIRE = 0 ;
    LOAD_A = 1;
    LOAD_B = 1;
    BANCO_WIRE = 0 ;
    MEM_TO_REG = 0;
    LOAD_MDR = 1;
    PROX_ESTADO = BUSCA;
   end
  
 endcase
endmodule
