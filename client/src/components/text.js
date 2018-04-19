import React, { Component } from 'react'
import classNames from 'classnames';

export default class Text extends Component {
  constructor(props) {
    super(props);
    this.state = {
      truncate: true
    }
    this.toggleBody = this.toggleBody.bind(this);
  }

  toggleBody(e) {
    e.preventDefault();
    e.stopPropagation();
    this.setState({ truncate: !this.state.truncate });
  }

  render() {
    const className = classNames(this.props.className,
                      this.state.truncate ? 'clickable text-truncate' : 'clickable')
    return (
      <p className={className} onClick={this.toggleBody}>
        {this.props.children}
      </p>
    )
  }
}

