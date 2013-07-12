fs = require 'fs'
expect = require('chai').expect
helpers = require './helpers'

describe 'Storage', ->

    {File, RemoteStoragePermission} = require '../stores/models'

    before helpers.destroyAll RemoteStoragePermission
    before helpers.destroyAll File
    before helpers.init
    before helpers.createTestPermission RemoteStoragePermission
    before helpers.makeTestClient

    # after  helpers.destroyAll RemoteStoragePermission
    # after  helpers.destroyAll RemoteStorageDocument
    after  helpers.killServer


    describe 'PUT', ->

        doc = key: 'value'

        it 'should allow requests', (done) ->
            @client.put 'public/storage/test/doc1', doc, done

        it 'should allow requests', (done) ->
            @client.put 'public/storage/test/doc2', doc, done

        it 'should allow requests', (done) ->
            @client.put 'public/storage/test/subfolder/doc3', doc, done


    describe 'GET', ->

        it 'should allow requests', (done) ->
            @client.get "public/storage/test", done

        it 'should reply with proper structure', ->
            expect(@body).to.have.property 'doc1'
            expect(@body).to.have.property 'doc2'
            expect(@body).to.have.property 'subfolder/'

        it 'should allow requests', (done) ->
            @client.get "public/storage/test/subfolder", done

        it 'should reply with proper structure', ->
            expect(@body).to.have.property 'doc3'

        it 'should allow requests', (done) ->
            @client.get "public/storage/test/subfolder/doc3", done

        it 'should reply with proper structure', ->
            console.log 'HERE', @body
            expect(@body).to.have.property 'key', 'value'
