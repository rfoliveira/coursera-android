package course.labs.activitylab;

public final class AuxiliarFunctions {
	static String getMethodName() {
		return Thread.currentThread().getStackTrace()[3].getMethodName() + "()";
	}
}