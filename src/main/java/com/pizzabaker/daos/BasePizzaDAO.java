package com.pizzabaker.daos;

import java.sql.Array;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.pizzabaker.entities.BasePizza;

public class BasePizzaDAO {

	
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//----------------------------------------- PUBLIC METHODS -----------------------------------------
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------

	public List<BasePizza> selectBasePizzas() throws DBConnectionException {
		Connection connection = null;
		try {
			connection = DBConnection.GetConnection();
			return selectBasePizzas(connection, null);
			/*CallableStatement callableStatement = connection.prepareCall("{ ? = call get_five() }");
			callableStatement.registerOutParameter(1, Types.BIGINT);
			callableStatement.execute();
			System.out.println(callableStatement.getLong(1));*/
			
			
			/*CallableStatement callableStatement = connection.prepareCall("{ ? = call fetch_all_pizza() }");
			callableStatement.registerOutParameter(1, Types.OTHER);
			callableStatement.execute();
			System.out.println("HOLA");*/
			
			
			
			/*ResultSet rs = callableStatement.getArray(1).getResultSet();
			while(rs.next()) {
				System.out.println(rs.getInt(1));
			}
			rs.close();
			callableStatement.close();
			connection.close();
			return new ArrayList<>();*/
		} catch (SQLException e) {
			try {
				connection.close();
			} catch(Exception ex) {}
			throw new DBConnectionException("There was an error trying to select the base pizzas", e);
		}
	}
	
	public Map<Long, BasePizza> getMapBasePizzasById() throws DBConnectionException{
		Map<Long, BasePizza> ret = new HashMap<>();
		List<BasePizza> listBasePizzas = selectBasePizzas();
		for(BasePizza basePizza : listBasePizzas) {
			ret.put(basePizza.getId(), basePizza);
		}
		return ret;
	}
	
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//---------------------------------------- INTERNAL METHODS ----------------------------------------
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	
	Map<Long, BasePizza> getMapBasePizzaById(Connection connection, String condition) throws SQLException{
		List<BasePizza> listPizzas = selectBasePizzas(connection, condition);
		Map<Long, BasePizza> ret = new HashMap<>();
		for(BasePizza pizza : listPizzas) {
			ret.put(pizza.getId(), pizza);
		}
		return ret;
	}
	
	List<BasePizza> selectBasePizzas(Connection connection, String condition) throws SQLException{
		String query = "SELECT * FROM pizza";
		if(condition != null && !condition.trim().isEmpty()) {
			query += " WHERE " + condition;
		}
		PreparedStatement ps = connection.prepareStatement(query);
		ResultSet rs = ps.executeQuery();
		List<BasePizza> ret = new ArrayList<>();
		while(rs.next()) {
			long id = rs.getLong("id");
			int size = rs.getInt("size");
			double price = rs.getDouble("price");
			BasePizza basePizza = new BasePizza(id, size, price);
			ret.add(basePizza);
		}
		rs.close();
		ps.close();
		return ret;
	}
}
