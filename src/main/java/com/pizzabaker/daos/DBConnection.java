package com.pizzabaker.daos;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {

	public static Connection GetConnection() throws SQLException {
		String url = "jdbc:postgresql://localhost/pizza_baker";
		Properties props = new Properties();
		props.setProperty("user","postgres");
		props.setProperty("password","tribus1234");
		//props.setProperty("ssl","true");
		return DriverManager.getConnection(url, props);
	}
}
