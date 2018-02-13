import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchHouse } from '../actions';
import { Link } from 'react-router-dom';
import Moment from 'react-moment';

import _ from 'lodash';

class PantryPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      type: 'password'
    }
    this.showHide = this.showHide.bind(this);
  }

  nextDate() {
    const today = new Date();
    if (today.getDate() < 15) {
      return new Date(today.getYear(), today.getMonth(), 15).toString()
    }
    else {
      return new Date(today.getYear(), today.getMonth(), 1).toString()
    }
  }

  componentDidMount() {
    this.props.fetchHouse(this.props.user.house_slug_id);
  }

  showHide(e){
    e.preventDefault();
    e.stopPropagation();
    this.setState({
      type: this.state.type === 'input' ? 'password' : 'input'
    })
  }

  // Todo : onclick should reveal password
  password(value) {
    return (
      <div className="input-group mb-1 mr-sm-1">
        <label className="sr-only" for="inlineFormInputGroupUsername2">Password</label>
        <input type={this.state.type}
        className="form-control"
        value={value}
        />
        <div className="input-group-addon">
          <div onClick={this.showHide} className="input-group-text" style={{'font-size': '21px', cursor: 'pointer'}}>👀</div>
        </div>
      </div>
    );
  }

  render() {
    const { house } = this.props;

    if (!house) {
      return '...';
    }

    return (
      <div className="card mb-4 d-block d-lg-block">
        <div className="card-body">
          <h6 className="mb-3">Produits du quotidien <small>· <a href="https://man.hackerhouse.paris/vivre/courses-produit-du-quotidien" target="_blank">Aide</a></small></h6>
          <p>Courses à faire avant le&nbsp;
            <strong><Moment format="DD/MM/YY">{this.nextDate()}</Moment></strong>
          </p>

          <form>
            <p>💰 <small>{house.pantry_budget}€ pour 15 jours</small></p>

            <div className="input-group mb-1 mr-sm-1">
              <label className="sr-only" for="inlineFormInputGroupLogin">Login</label>
              <input type="text" style={{'text-overflow': 'ellipsis'}} className="form-control" value={house.pantry_login} />
              <div className="input-group-addon">
                <div className="input-group-text" style={{'font-size': '21px'}}>👈</div>
              </div>
            </div>

            {this.password(house.pantry_password)}

            <div className="input-group mb-1 mr-sm-1">
              <label className="sr-only" for="inlineFormInputGroupLogin">CVC</label>
              <input type="text" style={{'text-overflow': 'ellipsis'}} className="form-control" value="745" />
              <div className="input-group-addon">
                <div className="input-group-text" style={{'font-size': '21px'}}>💳</div>
              </div>
            </div>
            <a  className="btn btn-outline-primary btn-sm btn-block"
                href={house.pantry_url}
                target="_blank">Faire les courses</a>
          </form>
        </div>
      </div>
    );
  }
}

function mapStateToProps(state, ownProps) {
  const { house_slug_id } = state.session.user;
  return { user: state.session.user, house: state.houses[house_slug_id] };
}

export default connect(mapStateToProps, { fetchHouse })(PantryPanel);