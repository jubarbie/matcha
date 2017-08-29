import React, { Component } from 'react';
import logo from './logo.svg';
import './css/normalize.css';
import './css/skeleton.css';
import './css/darkroom.css';

class App extends Component {
	state = {users: []}

	componentDidMount() {
		fetch('/users')
			.then(res => res.json())
			.then(users => this.setState({ users }));
	}

	render() {
		return (
				<div className="App">
				<h1>Membres</h1>
				<div className="row">
				{this.state.users.map(user =>
						<div className="four columns" key={user.id}>
							<div>{user.username}</div>
							<div>Nom: {user.fname}</div>
							<div>Prénom: {user.lname}</div>
							<div>{user.date_of_birth}</div>
						</div>
						)}
				</div>
				</div>
			   );
	}		
}

export default App;
