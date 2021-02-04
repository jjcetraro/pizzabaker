package com.pizzabaker.daos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import com.pizzabaker.entities.Ingredient;
import com.pizzabaker.entities.IngredientDetail;
import com.pizzabaker.entities.Supplier;

public class IngredientDAO {

	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//----------------------------------------- PUBLIC METHODS -----------------------------------------
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------

	public Ingredient selectIngredientById(long id) throws NoDataException, DBConnectionException {
		List<Ingredient> ingredients = selectIngredients(true);
		for(Ingredient ingredient : ingredients) {
			if(ingredient.getId() == id) return ingredient;
		}
		throw new NoDataException("There is no ingredient with id '"+id+"'", null);
	}
	
	public List<Ingredient> selectIngredients(boolean includeHidden) throws DBConnectionException {
		Connection connection = null;
		try {
			connection = DBConnection.GetConnection();
			Map<Long, Ingredient> mapIngredientsById = getMapIngredientsById_lazy(connection, "not deleted");
			String condition = "not deleted";
			if(!includeHidden) {
				condition += " AND not is_hidden";
			}
			Map<Long, List<IngredientDetail>> mapIngredientDetailsByIngredientId = getMapIngredientsDetailsByIngredientId(connection, condition);
			List<Ingredient> ret = new ArrayList<>();
			for(Entry<Long, Ingredient> entry : mapIngredientsById.entrySet()) {
				Ingredient ingredient = entry.getValue();
				if(mapIngredientDetailsByIngredientId.containsKey(ingredient.getId())) {
					ingredient.setIngredientDetails(mapIngredientDetailsByIngredientId.get(ingredient.getId()));
					ret.add(ingredient);
				}
			}
			connection.close();
			return ret;
		} catch(SQLException e) {
			try {
				connection.close();
			} catch(Exception ex) {}
			throw new DBConnectionException("There was an error trying to get the ingredients", e);
		}
	}
	
	public void deleteIngredientDetail(long ingredientDetailId) throws DBConnectionException {
		Connection connection = null;
		try {
			connection = DBConnection.GetConnection();
			PreparedStatement ps = connection.prepareStatement("UPDATE ingredient_detail SET deleted=true WHERE id=" + ingredientDetailId);
			ps.executeUpdate();
			ps.close();
			connection.close();
		} catch (SQLException e) {
			try {
				connection.close();
			} catch(Exception ex) {}
			throw new DBConnectionException("There was an error trying delete the ingredient detail with id '"+ingredientDetailId+"'", e);
		}
	}
	
	public void changeVisibilityIngredientDetail(long ingredientDetailId) throws DBConnectionException {
		Connection connection = null;
		try {
			connection = DBConnection.GetConnection();
			PreparedStatement ps = connection.prepareStatement("UPDATE ingredient_detail SET is_hidden=(not is_hidden) WHERE id=" + ingredientDetailId);
			ps.executeUpdate();
			ps.close();
			connection.close();
		} catch (SQLException e) {
			try {
				connection.close();
			} catch(Exception ex) {}
			throw new DBConnectionException("There was an error trying hide/show the ingredient detail with id '"+ingredientDetailId+"'", e);
		}
	}
	
	public void insertIngredient(Ingredient ingredient) throws DBConnectionException {
		Connection connection = null;
		try {
			connection = DBConnection.GetConnection();
			PreparedStatement ps = connection.prepareStatement("INSERT INTO ingredient (name, deleted) VALUES (?, ?)", PreparedStatement.RETURN_GENERATED_KEYS);
			ps.setString(1, ingredient.getName());
			ps.setBoolean(2, false);
			ps.execute();
			ResultSet rs = ps.getGeneratedKeys();
			if(!rs.next()) {
				rs.close();
				ps.close();
				connection.close();
				throw new DBConnectionException("We couldnt get the auto generated id", null);
			}
			long id = rs.getLong(1);
			rs.close();
			ps.close();
			ps = connection.prepareStatement("INSERT INTO ingredient_detail (id_ingredient, region, id_supplier, price, quantity, is_hidden, deleted) VALUES (?, ?, ?, ?, ?, ?, ?)");
			for(IngredientDetail detail : ingredient.getIngredientDetails()) {
				ps.setLong(1, id);
				ps.setString(2, detail.getProvince());
				ps.setLong(3, detail.getSupplier().getId());
				ps.setDouble(4, detail.getPrice());
				ps.setInt(5, detail.getQuantity());
				ps.setBoolean(6, detail.isHidden());
				ps.setBoolean(7, false);
				ps.execute();
			}
			ps.close();
			connection.close();
		} catch (SQLException e) {
			try {
				connection.close();
			}catch(Exception ex) {}
			throw new DBConnectionException("There was an error trying to insert an ingredient", e);
		}
	}
	
	
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//---------------------------------------- INTERNAL METHODS ----------------------------------------
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------

	Map<Long, IngredientDetail> getMapIngredientDetailById(Connection connection, String condition) throws SQLException{
		Map<Long, List<IngredientDetail>> map = getMapIngredientsDetailsByIngredientId(connection, condition);
		Map<Long, IngredientDetail> ret = new HashMap<>();
		for(Entry<Long, List<IngredientDetail>> entry : map.entrySet()) {
			for(IngredientDetail ingDetail : entry.getValue()) {
				ret.put(ingDetail.getId(), ingDetail);
			}
		}
		return ret;
	}
	
	Map<Long, String> getMapIngredientNameByIngredientDetailId(Connection connection, String condition) throws SQLException{
		Map<Long, List<IngredientDetail>> map = getMapIngredientsDetailsByIngredientId(connection, condition);
		Map<Long, Ingredient> mapIngredientById = getMapIngredientsById_lazy(connection, condition);
		Map<Long, String> ret = new HashMap<>();
		for(Entry<Long, List<IngredientDetail>> entry : map.entrySet()) {
			long ingredientId = entry.getKey();
			for(IngredientDetail detail : entry.getValue()) {
				ret.put(detail.getId(), mapIngredientById.get(ingredientId).getName());
			}
		}
		return ret;
	}
	
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//---------------------------------------- PRIVATE METHODS  ----------------------------------------
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	
	private Map<Long, List<IngredientDetail>> getMapIngredientsDetailsByIngredientId(Connection connection, String condition) throws SQLException{
		Map<Long, Supplier> mapSuppliers = new SupplierDAO().getMapSuppliersById(connection, null);
		String query = "SELECT * FROM ingredient_detail";
		if(condition != null && !condition.trim().isEmpty()) {
			query += " WHERE " + condition;
		}
		query += " ORDER BY id";
		PreparedStatement ps = connection.prepareStatement(query);
		ResultSet rs = ps.executeQuery();
		Map<Long, List<IngredientDetail>> map = new HashMap<>();
		while(rs.next()) {
			long id = rs.getLong("id");
			long idIngredient = rs.getLong("id_ingredient");
			String province = rs.getString("region");
			long idSupplier = rs.getLong("id_supplier");
			Supplier supplier = new Supplier(mapSuppliers.get(idSupplier));
			double price = rs.getDouble("price");
			int quantity = rs.getInt("quantity");
			boolean hidden = rs.getBoolean("is_hidden");
			IngredientDetail ingredientDetail = new IngredientDetail(id, province, price, quantity, supplier, hidden);
			if(!map.containsKey(idIngredient)) {
				map.put(idIngredient, new ArrayList<>());
			}
			map.get(idIngredient).add(ingredientDetail);
		}
		rs.close();
		ps.close();
		return map;
	}
	
	private Map<Long, Ingredient> getMapIngredientsById_lazy(Connection connection, String condition) throws SQLException{
		String query = "SELECT * FROM ingredient";
		if(condition != null && !condition.trim().isEmpty()) {
			query += " WHERE " + condition;
		}
		PreparedStatement ps = connection.prepareStatement(query);
		ResultSet rs = ps.executeQuery();
		Map<Long, Ingredient> map = new HashMap<>();
		while(rs.next()) {
			long id = rs.getLong("id");
			String name = rs.getString("name");
			Ingredient ingredient = new Ingredient(id, name, null);
			map.put(id, ingredient);
		}
		rs.close();
		ps.close();
		return map;
	}
	
}
