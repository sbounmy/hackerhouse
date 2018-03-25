import React, { Component } from 'react';
import { connect } from 'react-redux';
import { createSession } from '../actions';
import { Link } from 'react-router-dom';
import { Field, reduxForm } from 'redux-form';
import { destroySession } from '../actions';

class NavBar extends Component {
  renderNavLinks() {
    if (this.props.user) {
      return (
        <div>
          <h3>Welcome {this.props.user.firstname},</h3>
        </div>
      );
    } else {
      return (
        <Link to="/sessions/new">
          Se connecter
        </Link>
      );
    }
  }
  render() {
    if (!this.props.user) {
      return ""
    }
    return (
      <nav className="navbar navbar-expand-md fixed-top navbar-dark bg-primary app-navbar">

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
          <li className="nav-item">
            <a className="nav-link" href="profile/index.html">Profile</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" data-toggle="modal" href="#msgModal">Messages</a>
          </li>

          <li className="nav-item d-md-none">
            <a className="nav-link" href="notifications/index.html">Notifications</a>
          </li>
          <li className="nav-item d-md-none">
            <a className="nav-link" data-action="growl">Growl</a>
          </li>
          <li className="nav-item d-md-none">
          </li>

        </ul>

        <form className="form-inline float-right d-none d-md-flex">
          <input className="form-control" type="text" data-action="grow" placeholder="Search"/>
        </form>

        <ul id="#js-popoverContent" className="nav navbar-nav float-right mr-0 d-none d-md-flex">
          <li className="nav-item">
            <a className="app-notifications nav-link" href="notifications/index.html">
              <span className="icon icon-bell"></span>
            </a>
          </li>
          <li className="nav-item ml-2">
            <a
              title= "@+ sous le Bus!"
              className='nav-link'
              href="/sessions/new"
              onClick={this.props.destroySession}>
              <span class="icon icon-log-out"></span>
            </a>
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

export default connect(mapStateToProps, { destroySession })(NavBar);