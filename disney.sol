// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney{
	
	// ------- Declaraciones iniciales ---------
	
	// Instancia del contrato token
	ERC20Basic private token;

	// Direccion de Disney (owner)
	address payable public owner;

	// Constructor
	constructor ()public {
		token = new ERC20Basic(10000);
		owner = msg.sender;
	}

	// Estructura de datos apara almacenar a los clientes de Disney
	struct cliente {
		uint tokens_comprados;
		string [] atracciones_disfrutadas;
	}

	//Mapping para el regstro de clientes
	mapping (address => cliente) public Clientes; 


	// ------- GESTION DE TOKENS -----------

	// Funcion para etablecer el precio de un TOKEN
	function PrecioTokens(uint _numTokens) internal pure returns (uint){
		// Conversion de Tokens a Ethers
		return _numTokens*(1 ether);
	}

	// Funcion para comprar TOkens en disney
	function CompraTokens(uint _numTokens) public payable {
		//Establecer el precio de los Tokens
		uint coste = PrecioTokens(_numTokens);

		//Se evalua el dinero que el cliente paga por los Tokens
		require (msg.value >= coste, "Compra menos Tokens o paga con mas ethers");

		//diferencia de lo que el cliente paga
		uint returnValue = msg.value - coste;

		//Disney retorna la cantidad de ethers al cliente
		msg.sender.transfer(returnValue);

		// Obtencion del numero de tokens disponibles
		uint Balance = balanceOf();
		require(_numTokens <= Balance, "Compra un numero menor de Token");

		//Se transfiere el numero de tokens al cliente
		token.transfer(msg.sender, _numTokens);

		//Registro de tokens comprados
		Clientes[msg.sender].tokens_comprados += _numTokens;
	}

	// Balance de tokens del contrato disney
	function balanceOf() public view returns (uint){
		return token.balanceOf(address(this));
	}

	// Visualizar el numero de tokens de un Cliente
	function MisTokens() public view returns (uint){
		return token.balanceOf(msg.sender);
	}

	// Funcion para generar mas tokens
	function GeneraTokens(uint _numTokens) public Unicamente(msg.sender){
		token.increaseTotalSupply(_numTokens);
	}

	// Modificador para controlar las funciones ejecutables por disney
	modifier Unicamente(address _direccion){
		require(_direccion == owner, "No tienes permisos");
		_;
	}

	// -------- GESTION DE DISNEY ---------

	// Eventos
	event disfruta_atraccion(string, uint256, address);
	event nueva_atraccion(string, uint256);
	event baja_atraccion(string);

	// Estructura de atraccion
	struct atraccion {
		string nombre_atraccion;
		uint precio_atraccion;
		bool estado_atraccion;
	}

	// Mapping para relacion un nombre de atraccion con estructura de datos
	mapping (string => atraccion) public MappingAtracciones;

	//Array nombre atracciones
	string [] Atracciones;

	// Mapping para relacionar cliente con su historial
	mapping (address => string []) HistorialAtracciones;

	// Solo ejecutable por disney
	function NuevaAtraccion(string memory _nombreAtraccion, uint _precio) public Unicamente (msg.sender){
		// Creacion de una atraccion en disney
		MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);

		//Almacenamiento de nombre en array
		Atracciones.push(_nombreAtraccion);

		// Emision de evento para nueva atraccion
		emit nueva_atraccion(_nombreAtraccion, _precio);
	}

	// Dar de baja atraccion
	function BajaAtraccion (string memory _nombreAtraccion) public Unicamente(msg.sender){
		//El estado de la atraccion pasa a FALSE => no esta en uso
		MappingAtracciones[_nombreAtraccion].estado_atraccion = false;

		// Emision de evento
		emit baja_atraccion(_nombreAtraccion);
	}

	// Visualizar las atracciones
	function AtraccionesDisponibles() public view returns (string [] memory){
	    return Atracciones;
	}

	// Funcion para subirse a una atraccion y pagar
	function SubirseAtraccion (string memory _nombreAtraccion) public {
		// Precio de la atraccion
		uint tokens_atraccion = MappingAtracciones[_nombreAtraccion].precio_atraccion;

		// Verificar el estado de la atraccion
		require (MappingAtraccioes[_nombreAtraccion].estado_atraccion == true, "La atraccion no esta disponible en este momento");

		// Verificar el numero de tokens del cliente
		require(tokens_atraccion <= MisTokens(), "Necesitas mas Tokens para subirte a esta atraccion");

		// El cliente paga la atraccion en tokens
		// se creo transfer_disney debido a que al usar transfer se utilizaba solo la direccion del contrato
		token.transfer_disney(msg.sender, address(this), tokens_atraccion);

		// Almacenamiento en el historial
		HistorialAtracciones[msg.sender].push(_nombreAtraccion);

		// Emision del evento para disfrutar de la atraccion
		emit disfruta_atraccion(_nombreAtraccion, tokens_atraccion, msg.sender);
	}

	// Visualizar el historial de un cliente
	function Historial() public view returns (string [] memory){
		return HistorialAtracciones[msg.sender];
	}

	// Funcion para que un cliente de disney pueda devolver Tokens
	function DevolverTokens (uint _numTokens) public payable {
		// El numero de tokens a devolver es positivo
		require (_numTokens > 0, "Necesitas devolver una cantidad positiva de tokens");

		// El usuario debe temer el numeor de tokens a devolver
		require (_numTokens <= MisTokens(), "No tienes los tokens suficientes");

		// EL cliente devuelve los tokens
		token.transfer_disney(msg.sender, address(this), _numTokens);

		// Devolucion de ethers
		msg.sender.transfer(PrecioTokens(_numTokens));
	}
}

