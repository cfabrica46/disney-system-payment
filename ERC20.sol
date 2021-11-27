// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//Direccion => 0x4dc07d5d171a00841D97799684995a81d8D56F2A
//Interface de nuestro token ERC20
interface IERC20{
	//Devuelve la cantidad de tokens en existencia
	function totalSupply() external view returns (uint256);

	//Devuelve la cantidad de tokens para una direccion indeicada por parametro
	function balanceOf(address account) external view returns (uint256);
	
	//Devuelve el numero de token que el spender podra gastar en nombre del propietario
	function allowance(address owner, address spender) external view returns (uint256);

	//Devuelve un valor booleano resultado de la operacion indicada
	function transfer(address recipent, uint256 amount) external returns (bool);

	function transfer_disney(address _cliente,address recipent, uint256 amount) external returns (bool);

	//Devuelve un valor booleano con el resultado de la operacion de gasto
	function approve(address spender, uint256 amount) external returns (bool);

	//Devuelve un valor booleano con el resultado de la operacion de paso de una cantidad de tokens usando el metodo allowance()
	function transferFrom(address sender, address recipent, uint256 amount) external returns (bool);

	//Evento que se debe emitir cuando una cantidad de tokens pasa de un origen a un destino
	event Transfer(address indexed from, address indexed to, uint256 value);

	//Evento que se debe emitir cuando se establece una asignacion con el metodo allowance()
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

//Implementacion de las funciones del token ERC20
contract ERC20Basic is IERC20{

	string public constant name = "ERC20BlockcahinAZ";
	string public constant symbol = "ERC";
	uint8 public constant decimals = 18;

	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);

	using SafeMath for uint256;

	mapping (address => uint) balances;
	mapping (address => mapping (address => uint)) allowed;
	uint256 totalSupply_;

	constructor (uint256 initialSupply) public{
		totalSupply_ = initialSupply;
		balances[msg.sender] = totalSupply_;
	}

	function totalSupply() public override view returns (uint256){
		return totalSupply_;
	}

	function increaseTotalSupply(uint newTokensAmount) public{
		totalSupply_ += newTokensAmount;
		balances[msg.sender] += newTokensAmount;
	}

	function balanceOf(address tokenOwner) public override view returns(uint256){
		return balances[tokenOwner];
	}

	function allowance(address owner, address delegate) public override view returns (uint256){
		return allowed[owner][delegate];
	}

	function transfer(address receiver, uint256 numTokens) public override returns (bool){
		require(numTokens <= balances[msg.sender]);
		balances[msg.sender] = balances[msg.sender].sub(numTokens);
		balances[receiver] = balances[receiver].add(numTokens);
		emit Transfer(msg.sender, receiver, numTokens);
		return true;
	}

	function transfer_disney(address _cliente, address receiver, uint256 numTokens) public override returns (bool){
		require(numTokens <= balances[_cliente]);
		balances[msg.sender] = balances[_cliente].sub(numTokens);
		balances[receiver] = balances[receiver].add(numTokens);
		emit Transfer(msg.sender, receiver, numTokens);
		return true;
	}

	function approve(address delegate, uint256 numTokens) public override returns (bool){
		allowed[msg.sender][delegate] = numTokens;
		emit Approval(msg.sender, delegate, numTokens);
		return true;
	}

	function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
		require(numTokens <= balances[owner]);
		require(numTokens <= allowed[owner][msg.sender]);

		balances[owner] = balances[owner].sub(numTokens);
		allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
		balances[buyer] = balances[buyer].add(numTokens);
		emit Transfer(owner, buyer, numTokens);
		return true;
	}
	
}
