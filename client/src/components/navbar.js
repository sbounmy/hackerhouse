import React, { Component } from 'react';
import { connect } from 'react-redux';
import { createSession } from '../actions';
import { NavLink, Link, withRouter } from 'react-router-dom';
import { Field, reduxForm } from 'redux-form';
import { destroySession } from '../actions';
import _ from 'lodash';

class NavBar extends Component {
  logout = async () => {
     await this.props.destroySession()
     this.props.history.push('/sessions/new')
  }

  renderToggle() {
    if (this.props.user && !this.props.user.house_slug_id) {
      return ''
    }
    return (
      <div class="dashboard-toggle btn-group btn-group-toggle mr-auto" data-toggle="buttons">
        <NavLink className="btn btn-light border mr-0" exact to="/dashboard" style={{width: '160px'}}><strong>🤖 Moi</strong></NavLink>
        <NavLink className="btn btn-light border" exact to="/dashboard/house" style={{width: '160px'}}><strong>🏡 Ma HackerHouse</strong></NavLink>
      </div>
    )
  }

  render() {
    if (!this.props.user) {
      return ""
    }
    return (
      <nav className="navbar navbar-expand-md navbar-dark fixed-top bg-dark app-navbar">
      <a className="navbar-brand" href="index.html">
        <img src="/logo-hh.png" width="45" alt="brand"/>
      </a>

      <button className="navbar-toggler navbar-toggler-right d-md-none" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
        <span className="navbar-toggler-icon"></span>
      </button>

      <div className="collapse navbar-collapse" id="navbarResponsive">
        <ul className="navbar-nav mr-auto">
          <li className="nav-item active">
            <a className="nav-link" href="index.html">Home <span className="sr-only">(current)</span></a>
          </li>
{/*          <li className="nav-item">
            <a className="nav-link" href="profile/index.html">Profile</a>
          </li>*/}
{/*          <li className="nav-item">
            <a className="nav-link" data-toggle="modal" href="#msgModal">Messages</a>
          </li>
*/}
          <li className="nav-item d-md-none">
            <a className="nav-link" href="notifications/index.html">Notifications</a>
          </li>
          <li className="nav-item d-md-none">
            <a className="nav-link" data-action="growl">Growl</a>
          </li>
          <li className="nav-item d-md-none">
          </li>

        </ul>

        {this.renderToggle()}

{/*        <form className="form-inline float-right d-none d-md-flex">
          <input className="form-control" type="text" data-action="grow" placeholder="Search"/>
        </form>
*/}
        <ul id="#js-popoverContent" className="nav navbar-nav float-right mr-0 d-none d-md-flex">
{/*          <li className="nav-item">
            <a className="app-notifications nav-link" href="notifications/index.html">
              <span className="icon icon-bell"></span>
            </a>
          </li>*/}
          <li className="nav-item ml-2">
            <Link to="/sessions/new"
                  title= "@+ sous le Bus!"
                  className='nav-link logout'
                  onClick={this.logout}>
                  <span className="icon icon-log-out"></span>
            </Link>
          </li>
        </ul>

        <ul className="nav navbar-nav d-none" id="js-popoverContent">
          <li className="nav-item"><a className="nav-link" href="#" data-action="growl">Growl</a></li>
          <li className="nav-item"><a className="nav-link" href="login/index.html">Logout</a></li>
        </ul>
      </div>
    </nav>
    );
  }
}

function mapStateToProps({session: { user }}) {
  return { user }
}
// https://github.com/ReactTraining/react-router/blob/master/packages/react-router/docs/guides/blocked-updates.md
export default withRouter(connect(mapStateToProps, { destroySession })(NavBar));