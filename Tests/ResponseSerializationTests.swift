//
//  ResponseSerializationTests.swift
//
//  Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Alamofire
import Foundation
import XCTest

private func httpURLResponse(forStatusCode statusCode: Int, headers: HTTPHeaders = [:]) -> HTTPURLResponse {
    let url = URL(string: "https://httpbin.org/get")!
    return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headers)!
}

// MARK: -

class DataResponseSerializationTestCase: BaseTestCase {

    // MARK: Properties

    private let error = AFError.responseSerializationFailed(reason: .inputDataNil)

    // MARK: Tests - Data Response Serializer

    func testThatDataResponseSerializerSucceedsWhenDataIsNotNil() {
        // Given
        let serializer = DataRequest.dataResponseSerializer()
        let data = "data".data(using: String.Encoding.utf8)!

        // When
        let result = serializer.serializeResponse(nil, nil, data, nil)

        // Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)
    }

    func testThatDataResponseSerializerFailsWhenDataIsNil() {
        // Given
        let serializer = DataRequest.dataResponseSerializer()

        // When
        let result = serializer.serializeResponse(nil, nil, nil, nil)

        // Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)

        if let error = result.error as? AFError {
            XCTAssertTrue(error.isInputDataNil)
        } else {
            XCTFail("error should not be nil")
        }
    }

    func testThatDataResponseSerializerFailsWhenErrorIsNotNil() {
        // Given
        let serializer = DataRequest.dataResponseSerializer()

        // When
        let result = serializer.serializeResponse(nil, nil, nil, error)

        // Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)

        if let error = result.error as? AFError {
            XCTAssertTrue(error.isInputDataNil)
        } else {
            XCTFail("error should not be nil")
        }
    }

    func testThatDataResponseSerializerFailsWhenDataIsNilWithNonEmptyResponseStatusCode() {
        // Given
        let serializer = DataRequest.dataResponseSerializer()
        let response = httpURLResponse(forStatusCode: 200)

        // When
        let result = serializer.serializeResponse(nil, response, nil, nil)

        // Then
        XCTAssertTrue(result.isFailure, "result is failure should be true")
        XCTAssertNil(result.value, "result value should be nil")
        XCTAssertNotNil(result.error, "result error should not be nil")

        if let error = result.error as? AFError {
            XCTAssertTrue(error.isInputDataNil)
        } else {
            XCTFail("error should not be nil")
        }
    }

    func testThatDataResponseSerializerSucceedsWhenDataIsNilWithEmptyResponseStatusCode() {
        // Given
        let serializer = DataRequest.dataResponseSerializer()
        let response = httpURLResponse(forStatusCode: 204)

        // When
        let result = serializer.serializeResponse(nil, response, nil, nil)

        // Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)

        if let data = result.value {
            XCTAssertEqual(data.count, 0)
        }
    }
}
