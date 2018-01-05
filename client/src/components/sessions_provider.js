import React, { Component } from 'react';
import { connect } from 'react-redux';
import { createLinkedInSession } from '../actions';
import qs from 'query-string';
import { LINKEDIN_REDIRECT_URI } from './sessions_new';

class SessionsProvider extends Component {
  componentDidMount() {
    const { code } = qs.parse(this.props.location.search);
    this.props.createLinkedInSession({code, redirect_uri: LINKEDIN_REDIRECT_URI}, this.props.history);
  }

  render() {
    const { code } = qs.parse(this.props.location.search)
    return (
      <p>Connecting....</p>
    );
  }
}

function mapStateToProps({ posts }) {
  return { posts }; // { posts } == { posts: posts }
}

export default connect(null, { createLinkedInSession })(SessionsProvider);