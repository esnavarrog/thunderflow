class Localizacion{
    constructor(callback){
        // obtener ubicacion
        if(navigator.geolocation){
            navigator.geolocation.getCurrentPosition((position)=>{
                this.latitude = position.coords.latitude;
                this.longitude = position.coords.longitude;
            });
        }else{
            alert('Tu navegador no soporta geolocalización!! :(');
        }
    }
}