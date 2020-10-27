#if !defined(_VEICULOS_CU_)
#define _VEICULOS_CU_
class Veiculo{
   public:
   //Metodos
   __host__ __device__   Veiculo(){};
   __host__ __device__   Veiculo(int id){
      ID     = id + 11;
      x       = 0;
      y       = 0;
      vel    = 0;
      tam = 0;
      vMax = 0;      
   };


   //Atributos
   int ID, x, y, tam, vel, vMax;
};

class Carro : public Veiculo{
public:
   __host__ __device__   Carro(){};
   __host__ __device__   Carro(int id){

         ID     = id+11;
         x       = 0;
         y       = 0;
         vel    = 0;
         tam   = 7; //metros de comprimento
         vMax = 28; //28 metros/s de velocidade maxima
      };

};

class Onibus : public Veiculo{
public:
   __host__ __device__   Onibus(){};
   __host__ __device__   Onibus(int id){
        ID      = id + 11;
         x       = 0;
         y       = 0;
         vel    = 0;
         tam   = 14; //metros de comprimento
         vMax = 23; //28 metros/s de velocidade maxima
      };

};

#endif
