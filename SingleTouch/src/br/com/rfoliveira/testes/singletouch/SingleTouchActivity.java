package br.com.rfoliveira.testes.singletouch;

import android.app.Activity;
import android.os.Bundle;

public class SingleTouchActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		
		setContentView(new SingleTouchEventView(this, null));
	}
}
                                                                                                                                                                                                                            