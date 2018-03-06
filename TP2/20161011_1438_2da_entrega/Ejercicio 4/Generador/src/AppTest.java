import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Random;
import java.util.concurrent.ThreadLocalRandom;
import java.util.Calendar;
import java.util.Random;
import java.text.SimpleDateFormat;

public class AppTest {
	
	public static void main(String[] args) {
		for (int i = 1; i <= 5; i++){
			// FECHA
		    Calendar unaFecha;
	        Random aleatorio;
	        aleatorio = new Random();
	        unaFecha = Calendar.getInstance();
	        unaFecha.set (aleatorio.nextInt(10)+2014, aleatorio.nextInt(12)+1, aleatorio.nextInt(30)+1);
	        SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.2016");
			//
			new AppTest().grabar("ventas-"+sdf.format(unaFecha.getTime()));
		}
	}
	
	public void grabar(String path) {
		
		FileWriter fw = null;
		PrintWriter pw = null;
		try{
			fw = new FileWriter(path);
			pw = new PrintWriter(fw);
			// GENERADOR DE CLIENTE
			for (int i = 1; i <= 5; i++){
				// GENERADOR DE HORA DE FACTURA
				int codigocliente = i;
				for (int j = 1; j <= 40; j++){
					int hora = ThreadLocalRandom.current().nextInt(0, 23 + 1);
					int minuto = ThreadLocalRandom.current().nextInt(0, 59 + 1);
					int segundo =  ThreadLocalRandom.current().nextInt(0, 59 + 1);
					int factura =  ThreadLocalRandom.current().nextInt(0, 59 + 1);
					int importe =  30;
					int razon =  ThreadLocalRandom.current().nextInt(0, 200 + 1);
					pw.println(hora+":"+minuto+":"+segundo+"|"+factura+"|"+i+"|"+razon+"|"+importe+",00");
				}
			}
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		finally {
				try {
					fw.close();
				} 
				catch (IOException e) {
					e.printStackTrace();
				}
		}
	}
}