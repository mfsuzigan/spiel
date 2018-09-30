private class TestListener implements FileListener
{
	public void fileChanged (File file)
	{
		try {
			Process p = Runtime.getRuntime().exec("wordpad /p FileMonitor.java");
			
		} catch (IOException e) {
			System.out.println("Excecao: " + e.getMessage());
		}
	}
}