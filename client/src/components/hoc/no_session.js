import React, { Component } from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

export default function (ComposedComponent) {
  class NoSession extends Component {
    componentWillMount() {
      if (this.props.user) {
        this.props.history.push('/dashboard');
      }
    }

    componentWillUpdate(nextProps) {
      if (nextProps.user) {
        this.props.history.push('/dashboard');
      }
    }

    PropTypes = {
      router: PropTypes.object,
    }

    render() {
      return <ComposedComponent {...this.props} />;
    }
  }

  function mapStateToProps({session: { user }}) {
    return { user };
  }

  return connect(mapStateToProps)(NoSession);
}