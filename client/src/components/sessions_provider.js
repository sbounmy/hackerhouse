import React, { Component } from 'react';
import { connect } from 'react-redux';
import { createLinkedInSession } from '../actions';
import qs from 'query-string';
import { LINKEDIN_REDIRECT_URI } from './sessions_new';

class SessionsProvider extends Component {
  componentDidMount() {
    if (this.props.authenticated) {
      this.props.history.push('/dashboard');
    }
    else {
      const { code } = qs.parse(this.props.location.search);
      this.props.createLinkedInSession({code, redirect_uri: LINKEDIN_REDIRECT_URI}, this.props.history);
    }
  }

  render() {
    const { code } = qs.parse(this.props.location.search)
    return (
      <div className='text-center'>
        <h3>Loading....</h3>
        <p>Remember to get up and stretch once in a while. 💪</p>
      </div>
    );
  }
}

function mapStateToProps({ session: { authenticated } }) {
  return { authenticated };
}

export default connect(mapStateToProps, { createLinkedInSession })(SessionsProvider);